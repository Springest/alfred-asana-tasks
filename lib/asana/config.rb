require 'yaml'

module Asana
  class Config
    def initialize
      @config = YAML.load_file "#{ENV['HOME']}/.asanaconfig.yml"
    end

    def api_key
      @config['api_key']
    end
  end
end
