#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-

require File.expand_path(File.dirname(__FILE__)) + "/../config/load"

reporter = Log::HadoopReporter.new :job_name => "Refine"

refiner = Extractor::ChinaPOI.new

STDIN.each do |line|
  begin
    line = line.strip
    obj = JSON[line]
    puts refiner.extract(obj).to_json
  rescue => e
    warn [e.message, e.backtrace].join "\n"
    reporter.count :Exception
  end
end
