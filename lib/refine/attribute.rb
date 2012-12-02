# -*- coding: UTF-8 -*-

module Refine
  class Attribute

    include Utility::Pattern

    attr_accessor :selector

    def initialize(name, pattern, selector)
      init(name, pattern)
      self.selector = selector
    end

    def match(section)
      if pattern.is_a? String
        values = Nokogiri::HTML(section).search(pattern)
        if values.empty?
          return nil
        else
          return values.first.content
        end
      elsif pattern.is_a? Regexp
      end
    end

  end
end
