# -*- coding: UTF-8 -*-

module Refine
  class Selector
    include Utility::Pattern

    attr_accessor :page_path
    attr_accessor :attributes

    def initialize(name, pattern, page_path, opts)
      init(name, pattern)
      self.page_path = page_path
      self.attributes = []
      @opts = opts
    end

    def match(body)
      null_record = {}
      if pattern.is_a? String
        sections = Nokogiri::HTML(body).search(pattern)
        if sections.empty?
          yield null_record
        else
          method = @opts[:node] ? :to_s : :inner_html
          sections.map(&method).each do |section|
            yield record_with_attributes(section, body)
          end
        end
      elsif pattern.is_a? Regexp
        matches = body.scan pattern
        if matches.empty?
          yield null_record
        else
          matches.each do |match|
            yield record_with_attributes(match[0], body)
          end
        end
      else
        raise "Bad pattern type:#{pattern}"
      end
    end

    def record_with_attributes(section, body)
      record = {}
      self.attributes.each do |attribute|
        value = attribute.match section, body
        record[attribute.name] = value.to_s.strip
      end

      return record
    end
  end
end
