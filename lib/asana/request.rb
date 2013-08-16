require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'cgi'

module Asana
  class Request
    def initialize path
      @path = path
      @uri = URI "https://app.asana.com/api/1.0#{@path}"
    end

    def get options={}
      @results = []
      fetch :type => :get, :data => options
    end

    def post options={}
      @results = []
      fetch :type => :post, :data => options
    end

    def put options={}
      @results = []
      fetch :type => :put, :data => options
    end

    private

    def fetch options={}
      uri = @uri

      type = options.fetch :type, :get
      req_data = options.fetch :data, nil
      url = uri.request_uri

      # $stderr.puts url

      session = Net::HTTP.new uri.host, uri.port
      session.use_ssl = true
      session.start do |http|
        if type == :post
          request = Net::HTTP::Post.new url, {'Content-Type' => 'application/json'}
          request.set_form_data req_data if req_data && req_data.instance_of?(Hash)
        elsif type == :put
          request = Net::HTTP::Put.new url, {'Content-Type' => 'application/json'}
          request.set_form_data req_data if req_data && req_data.instance_of?(Hash)
          # $stderr.puts req_data
        else
          unless req_data.nil?
            params = req_data.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&')
            url = url.concat('?').concat(params)
          end

          request = Net::HTTP::Get.new url
        end

        request.basic_auth config.api_key, ''

        response = http.request request
        # $stderr.puts response.header

        data = JSON.parse response.body

        # $stderr.puts data

        @results = data
      end
    end

    def config
      @config ||= Config.new
    end
  end
end
