class Request
  include HTTParty

  attr_accessor :domain, :url, :mime_type, :headers, :method, :body
  
  def initialize(attributes={})
    self.domain = attributes['domain']
    self.url = attributes['url']
    self.method = attributes['method']
    self.body = attributes['body']
    self.mime_type = attributes['mime']
    self.headers = attributes['headers'] || ''
  end
  
  def path
    [domain, url].join
  end
  
  def hit
    configure_by_mime_type

    self.headers.split('\n').each { |header| self.class.headers.merge! Crack::JSON.parse(header) }
    puts "Request headers: #{self.class.headers.class}: #{self.class.headers.inspect}"

    data = begin
      if body.blank?
        nil
      else
        mime_type == 'json' ? Crack::JSON.parse(self.body) : Crack::XML.parse(self.body)
      end
    rescue => e
      message = "Can't parse string to #{mime_type.upcase}: #{body.inspect}.<br/>Error was: #{e.to_s}"
      return self.class.with_error e
    end
    puts "DATA to send: #{data.class}: #{data.inspect}"
    
    begin
      response = if data.nil?
        self.class.send method.to_sym, path
      else 
        self.class.send method.to_sym, path, :body => data
      end
      { :code => response.response.code, :data => response.parsed_response, :message => message, :headers => response.headers.inspect }
    rescue => e
      self.class.with_error e
    end
  end

  def self.with_error(e)
    { :code => '', :data => '', :message => "#{e.class}: #{e.message} </br>#{e.backtrace.join('</br>')}", :headers => '' }
  end
  
  private
  
  def configure_by_mime_type
    self.class.headers.clear
    if mime_type == 'json'
      # self.class.format( :json )
      self.class.headers 'Content-Type' => 'application/json'
      self.body = '{}' if self.body.blank? and method != 'get'
    else
      # self.class.format( :xml )
      self.class.headers 'Content-Type' => 'application/xml'
    end
  end
  
end