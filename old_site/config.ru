require "rubygems"

require 'bundler'
Bundler.setup
Bundler.require

require File.join(File.dirname(__FILE__), "site")

run Site