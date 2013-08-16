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

          fork do
            req = Request.new "/projects/#{id}/tasks"
            tasks = req.get
            cache tasks['data'], "project_#{id}_tasks" if tasks['data']
          end

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
            search "project_#{id}_tasks", :name => term
          else
            cached "project_#{id}_tasks".slice(15) rescue []
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

        def find_project(id)
          fork do
            req = Request.new "/projects/#{id}"
            project = req.get
            cache project['data'], "project_#{id}" if project['data']
          end

          data = cached "project_#{id}"

          # $stderr.puts data

          return data if data

          nil
        end

        def find_task(id)
          fork do
            req = Request.new "/tasks/#{id}"
            task = req.get
            cache task['data'], "task_#{id}" if task['data']
          end

          data = cached "task_#{id}"

          # $stderr.puts data

          return data if data

          nil
        end

        def project_search(term)
          fork do
            req = Request.new "/projects"
            projects = req.get
            cache projects['data'], :projects if projects['data']
          end

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

        def cache data, type
          return if data.nil? || !data.any?

          File.open(cache_file(type), 'w') {|f| f.write data.to_json }
          puts data.size
        end

        def search type, conditions={}
          data = cached(type).to_set

          return [] unless data

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
          JSON.parse File.read(cache_file(type)) if File.exists? cache_file(type)
        end

        def cache_file type
          "./cache/#{type}.json"
        end
      end
    end
  end
end
