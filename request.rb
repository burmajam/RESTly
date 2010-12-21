class Request
  include HTTParty
  format :json

  attr_accessor :domain, :url, :mime_type, :method, :body
  
  def initialize(attributes={})
    self.domain = attributes['domain']
    self.url = attributes['url']
    self.method = attributes['method']
    self.body = attributes['body']
    self.mime_type = attributes['mime']
  end
  
  def path
    [domain, url].join
  end
  
  def hit
    if mime_type == 'json'
      self.class.format( :json ) 
      self.class.headers 'Content-Type' => 'application/json'
    else
      self.class.format( :xml )
      self.class.headers 'Content-Type' => 'application/xml'
    end
    data = begin
      if body.blank?
        nil
      else
        mime_type == 'json' ? Crack::JSON.parse(self.body) : Crack::XML.parse(self.body)
      end
    rescue => e
      message = "Can't parse string to #{mime_type.upcase}: #{body.inspect}.<br/>Error was: #{e.to_s}"
      nil
    end
    puts "DATA to send: #{data.class}: #{data.inspect}"
    response = if data.nil?
      self.class.send method.to_sym, path
    else 
      self.class.send method.to_sym, path, :body => data
    end
    { :code => response.response.code, :data => response.parsed_response, :message => message }
  end

  def self.with_error(e)
    { :code => nil, :data => nil, :message => e.to_s }
  end
end