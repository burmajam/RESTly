module Groundlink
  module Restly
    class Application < Sinatra::Base
      mime_type :json, "application/json"
      set :public, File.dirname(__FILE__) + '/public'
      
      get '/' do
        erb :request
      end
      post '/' do
        content_type :json
        begin
          request = Request.new params['request']
          request.hit
        rescue => e
          Request.with_error(e)
        end.to_json
      end
    end
  end
end
