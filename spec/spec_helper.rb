require "rubygems"
require "bundler"
require "sevn"
Bundler.require(:default, :development)
require 'coveralls'
Coveralls.wear!

Dir[File.dirname(__FILE__) + '/support/*.rb'].each {|file| require file }
