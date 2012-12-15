# -*- coding: UTF-8 -*-

module Refine
  class Attribute

    include Utility::Pattern

    attr_accessor :selector

    def initialize(name, pattern, selector, opts = {})
      init(name, pattern)
      self.selector = selector
      @full_doc = opts[:full_doc] || false
    end

    def match(section, body)
      doc = @full_doc ? body : section
      doc = doc.to_s.force_encoding("utf-8")

      if pattern.is_a? String
        values = Nokogiri::HTML(doc).search(pattern)
        return values.first.content unless values.empty?
      elsif pattern.is_a? Regexp
        match = doc.match pattern
        return match[1] if match
      end

      return nil
    end
  end
end
