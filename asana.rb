#!/usr/bin/env ruby
# encoding: utf-8

# Suppress net/https warnings about certificate checks
BEGIN { $VERBOSE = nil }

#$stdout.reopen("log", "w")
# $stderr.reopen("log", "w")

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require './bundle/bundler/setup'
require './lib/asana/config'
require './lib/asana/request'
require './lib/asana/alfred'

command = ARGV.shift

if command == 'filter'
  require 'alfred'
  require './lib/alfred/feedback/item'
  require './lib/alfred/feedback/file_item'

  require './lib/asana/alfred/filter'
else
  require './lib/asana/alfred/action'
end

Asana::Alfred.const_get(command.capitalize).execute(*ARGV)
