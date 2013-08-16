# coding: utf-8

module Asana
  module Alfred
    class Filter
      class << self
        def execute(*args)
          ::Alfred.with_friendly_error do |alfred|
            Alfred.bundle_id = alfred.bundle_id
            @feedback = alfred.feedback

            query = args.dup

            command = args.shift
            major   = args.shift
            minor   = args.empty? ? nil : args.join(' ')

            delegate(command, major, minor)

            puts "<?xml version=\"1.0\"?>\n".concat @feedback.to_alfred(query)
          end
        end

        def delegate(command, major, minor)
          return overview          unless command || command != 'overview'

          return project_list(minor) if command == 'list' && major == 'project'
          
          return open_project_or_task major if command == 'open' && major

          project_search [command, major, minor].join(' ').strip
        end

        def overview
          @feedback.add_item({
            :uid          => "#{Alfred.bundle_id} overview",
            :title        => "Search Asana projects, tags or tasks",
            :subtitle     => "Create, Open or Mark them as Done.",
            :arg          => "overview",
            :valid        => "no",
            :autocomplete => "",
            :icon         => {:type => "default", :name => "icon.png"}
          })
        end

        def open_project_or_task(id)
          if project = find_project(id)
            @feedback.add_item({
              :uid          => "#{Alfred.bundle_id} open",
              :title        => "Open #{project['name']} in Asana.",
              :subtitle     => "In your Asana fluid app or Browser.",
              :arg          => "open project #{project['id']}",
              :valid        => "yes",
              :autocomplete => "open project #{project['id']}",
              :icon         => {:type => "default", :name => "browser.png"}
            })
          elsif task = find_task(id)
            @feedback.add_item({
              :uid          => "#{Alfred.bundle_id} open",
              :title        => "Open #{task['name']} in Asana.",
              :subtitle     => "In your Asana fluid app or Browser.",
              :arg          => "open task #{task['id']}",
              :valid        => "yes",
              :autocomplete => "open task #{task['id']}",
              :icon         => {:type => "default", :name => "browser.png"}
            })
          end
        end

        def project_list(query)
          terms = query.split(' ')
          id    = terms.shift
          term  = terms.join(' ') rescue nil

          return unless project = find_project(id)

          async_get "projects/#{id}/tasks" do
            @feedback.add_item({
              :uid          => "#{Alfred.bundle_id} open",
              :title        => "Open #{project['name']} in Asana.",
              :subtitle     => "In your Asana fluid app or Browser.",
              :arg          => "open project #{project['id']}",
              :valid        => "yes",
              :autocomplete => "open project #{project['id']}",
              :icon         => {:type => "default", :name => "browser.png"}
            })

            @feedback.add_item({
              :uid          => "#{Alfred.bundle_id} create",
              :title        => "Create task in #{project['name']}",
              :subtitle     => "with name #{term}",
              :arg          => "create #{project['id']} #{project['workspace']['id']} #{term}",
              :valid        => "yes",
              :autocomplete => "create #{project['id']} #{term}",
              :icon         => {:type => "default", :name => "list.png"}
            })

            results = if term
              search "projects/#{id}/tasks", :name => term
            else
              cached "projects/#{id}/tasks".slice(15) rescue []
            end

            results.each do |task|
              @feedback.add_item({
                :uid          => "#{Alfred.bundle_id} open",
                :title        => "Open #{task['name']} in Asana.",
                :subtitle     => "In your Asana fluid app or Browser.",
                :arg          => "open task #{task['id']}",
                :valid        => "yes",
                :autocomplete => "open task #{task['id']}",
                :icon         => {:type => "default", :name => "browser.png"}
              })

              @feedback.add_item({
                :uid          => "#{Alfred.bundle_id} complete",
                :title        => "Complete task: #{task['name']}",
                :subtitle     => "complete #{task['id']}",
                :arg          => "complete #{task['id']}",
                :valid        => "yes",
                :autocomplete => "complete task #{task['id']}",
                :icon         => {:type => "default", :name => "complete.png"}
              })
            end
          end
        end

        def find_project(id)
          # $stderr.puts "Find project"
          async_get "projects/#{id}" do
            data = cached "projects/#{id}"
            # $stderr.puts data

            return data if data

            nil
          end
        end

        def find_task(id)
          # $stderr.puts "Find task"
          async_get "tasks/#{id}" do
            data = cached "tasks/#{id}"
            # $stderr.puts data

            return data if data

            nil
          end
        end

        def project_search(term)
          async_get 'projects' do
            results = search :projects, :name => term

            results.each do |project|
              @feedback.add_item({
                :uid          => "#{Alfred.bundle_id} open",
                :title        => "Open #{project['name']} in Asana.",
                :subtitle     => "In your Asana fluid app or Browser.",
                :arg          => "open project #{project['id']}",
                :valid        => "yes",
                :autocomplete => "open project #{project['id']}",
                :icon         => {:type => "default", :name => "browser.png"}
              })

              @feedback.add_item({
                :uid          => "#{Alfred.bundle_id} list",
                :title        => "Find tasks in #{project['name']}",
                :subtitle     => "project #{term}",
                :arg          => "project #{project['id']}",
                :valid        => "no",
                :autocomplete => "list project #{project['id']}",
                :icon         => {:type => "default", :name => "list.png"}
              })
            end
          end
        end

        def async_get endpoint, &blk
          pid = fork do
            if cache_expired?(endpoint)
              system "touch #{lock_file(endpoint)}"
              req = Request.new "/#{endpoint}"
              data = req.get
              cache data['data'], endpoint.gsub('/', '-') if data['data']
              system "rm #{lock_file(endpoint)}"
            end
          end

          Process.detach pid

          # Wait for the cache to arrive...
          # while File.exists?(lock_file(endpoint))
          #   sleep 1
          # end

          yield blk
        end

        def cache data, type
          return if data.nil? || !data.any?

          File.open(cache_file(type), 'w') {|f| f.write data.to_json }
          puts data.size
        end

        def search type, conditions={}
          return [] unless data = cached(type)
          data = data.to_set

          return data unless data.any?

          # First match all those that contain the term
          contains = data.select do |item|
            conditions.map do |field,condition|
              field = field.to_s

              unless item[field].nil?
                (item[field].match(/#{condition}/i) ? true : false) rescue false
              else
                false
              end
            end.all?
          end.to_set

          return [] unless contains.any?

          # Than match those that start with the term from that set
          starts_with = contains.select do |item|
            conditions.map do |field,condition|
              field = field.to_s

              if item[field]
                (item[field].to_s == condition || item[field].match(/^#{condition}/i) ? true : false) rescue false
              else
                false
              end
            end.all?
          end

          hits     = starts_with.map { |h| h['id'] }
          contains = contains.reject{|d| hits.include?(d['id']) }          

          # Put them in the right order
          # starts_with = starts_with.order_by{|n| n['name']}
          # contains    = contains.order_by{|n| n['name']}
          starts_with + contains
        end

        def cached type
          @cached ||= {}
          @cached[type] ||= JSON.parse File.read(cache_file(type)) if File.exists? cache_file(type)
        end

        def cache_file type
          type = type.to_s
          "./cache/#{type.gsub('/', '-')}.json"
        end

        def lock_file type
          "#{cache_file(type)}.lock"
        end

        def cache_expired? endpoint
          return true unless File.exists? cache_file(endpoint)
          return false if File.exists? lock_file(endpoint)
          return false if File.mtime(cache_file(endpoint)).to_i < Time.now.to_i-30
          true
        end

      end
    end
  end
end
