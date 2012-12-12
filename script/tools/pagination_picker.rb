#!/usr/bin/env ruby1.9
# -*- coding: UTF-8 -*-

abort 'requires ruby1.9 or later' if RUBY_VERSION < '1.9'

require "uri"
require "mechanize"

url = ARGV[0]
max = ARGV[1]

warn "Processing the page ==> #{url}"

if max
  left, right = 1, max.to_i

  while left < right
    middle = (left+right)/2
    test_url = url.gsub(/###index###/, middle.to_s)

    warn "Try test url ==> #{test_url}"
    has_next_page = false

    Mechanize.new.get(test_url) do |page|
      page.links.each do |link|
        if link.text =~ /下一页/
          has_next_page = true
          break
        end
      end
    end

    if has_next_page
      left = middle + 1
    else
      right = middle - 1
    end

    warn "The last page is @: #{left}"
  end
  puts url.gsub(/###index###/, "\t#{left.to_s}")
else
  Mechanize.new.get(url) do |page|
    page.links.each do |link|
      if link.text =~ /尾页/
        num = link.href.gsub(/^.*index-p(\d+)\.html$/, "\\1")
        puts url + "\t" + num
        break
      end
    end
  end
end


