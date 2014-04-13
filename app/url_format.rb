#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-

require File.expand_path(File.dirname(__FILE__)) + "/../config/load"

STDIN.each do |line|
  record = JSON[line]
  url = WWW::URLNormalizer.format record["shop_page_url"]
  puts url
end
