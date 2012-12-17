#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-

require File.expand_path(File.dirname(__FILE__)) + "/../config/load"

reporter = Log::HadoopReporter.new :job_name => "Spider"
spider = WWW::Spider.crawl_only("capken")

rule_name = ARGV[0]

extractor_class = Rule.const_get "#{rule_name.capitalize}Extractor"
extractor = extractor_class.new

STDIN.each do |line|
  begin
    url = WWW::Url.new line.strip

    spider.crawl(url) do |page|
      res = [:url, :code, :content_type, :origin].map do |method|
        page.send method
      end

      warn res.join("\t")

      extractor.extract(url, page.body) do |record|
        puts record.to_json
      end

      reporter.count :Processed
    end
  rescue => e
    warn [e.message, e.backtrace].join "\n"
    reporter.count :Exception
  end
end
