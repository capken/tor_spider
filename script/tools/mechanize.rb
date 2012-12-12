#!/usr/bin/env ruby1.9

abort 'requires ruby1.9 or later' if RUBY_VERSION < '1.9'

require "uri"
require "mechanize"

url = ARGV[0]
pattern = ARGV[1].to_s.empty? ? /.*/ : Regexp.new(ARGV[1])
host = ARGV[2] || url

m = Mechanize.new
m.user_agent_alias = 'Mac Safari'
m.get(url) do |page|
  warn "Processing the page ==> #{url}"
  page.links.each do |link|
    if link.href and link.href.match(pattern)
      puts "#{link.text.strip}\t#{link.href}\t#{URI.join(host, link.href)}"
    end
  end
end
