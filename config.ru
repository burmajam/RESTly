require 'rubygems'

require 'bundler'
Bundler.setup
Bundler.require :default

require 'erb'
require 'logger'

require File.dirname(__FILE__) + "/application.rb"
require File.dirname(__FILE__) + "/request.rb"

use Groundlink::Restly::Application
run Sinatra::Base