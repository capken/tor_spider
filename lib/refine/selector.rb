# -*- coding: UTF-8 -*-

module Refine
  class Selector
    include Utility::Pattern

    attr_accessor :page_path
    attr_accessor :attributes

    def initialize(name, pattern, page_path)
      init(name, pattern)
      self.page_path = page_path
      self.attributes = []
    end

    def match(body)
      null_record = {}
      if pattern.is_a? String
        sections = Nokogiri::HTML(body).search(pattern)
        if sections.empty?
          yield null_record
        else
          sections.map(&:inner_html).each do |section|
            yield record_with_attributes(section, body)
          end
        end
      elsif pattern.is_a? Regexp
        matches = body.scan pattern
        if matches.empty?
          yield null_record
        else
          matches.each do |match|
            yield record_with_attributes(match[1], body)
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
        record[attribute.name] = value
      end

      return record
    end
  end
end
