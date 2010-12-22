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

    puts "DATA to send: #{self.body.class}: #{self.body.inspect}"
    begin
      options = body.blank? ? {} : { :body => self.body }
      response = self.class.send method.to_sym, path, options
      { :code => response.response.code, :data => response.parsed_response, :message => '', :headers => response.headers.inspect }
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