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
            record = {}
            self.attributes.each do |attribute|
              value = attribute.match(section)
              record[attribute.name] = value
            end
            yield record
          end
        end
      end
    end
  end
end
