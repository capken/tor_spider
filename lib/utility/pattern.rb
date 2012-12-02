# -*- coding: UTF-8 -*-

module Utility
  module Pattern

    attr_reader :name, :pattern

    def init(name, pattern)
      @name = name
      @pattern = pattern
    end

    def is_xpath_pattern
      self.pattern.is_a? String
    end

    def is_regxp_pattern
      self.pattern.is_a? Regexp
    end

  end
end
