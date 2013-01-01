#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-

require "bson"
require 'mongo'

include Mongo

@client = MongoClient.new('localhost', 27017)
coll_name = ARGV[0]
@db     = @client['geo_db']
@coll   = @db[coll_name]

STDIN.each do |line|
  line = line.strip
  record = { :record => line, :resolve => "no" }
  @coll.insert record
end

puts @coll.count
