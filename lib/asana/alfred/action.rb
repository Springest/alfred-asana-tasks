# coding: utf-8

module Asana
  module Alfred
    class Action
      class << self
        def execute(*args)
          method = args.shift
          return send(method, *args) if method
        end

        def open(*args)
          id = args.pop
          url = "https://app.asana.com/0/#{id}/#{id}"

          command = "open #{url}"
          command = "open -a Asana #{url}" if File.exists? '/Applications/Asana.app'

          system command

          puts "Url opened in Asana!"
        end

        def complete(*args)
          id    = args.shift

          opts = { "completed" => true }

          begin
            req = Request.new "/tasks/#{id}"
            result = req.put(opts)
            status = "Task completed!"
          rescue => e
            # $stderr.puts e
            # $stderr.puts e.backtrace
            status = "Task completion FAILED!"
          ensure
            puts status
          end
        end

        def create(*args)
          project_id = args.shift
          workspace_id = args.shift

          opts = { "name" => args.join(' '), "project" => project_id, "workspace" => workspace_id }

          begin
            req = Request.new "/tasks"
            result = req.post(opts)
            req = Request.new "/tasks/#{result['data']['id']}/addProject"
            result = req.post({ "project" => project_id })
            status = "Task created!"
          rescue => e
            # $stderr.puts e
            # $stderr.puts e.backtrace
            status = "Task creation FAILED!"
          ensure
            puts status
          end
        end
      end
    end
  end
end