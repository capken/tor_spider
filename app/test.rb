#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-

require File.expand_path(File.dirname(__FILE__)) + "/../config/load"

class A < Refine::HTMLExtractor
  domain "www.baidu.com"
end

a = A.new
puts a.domain
