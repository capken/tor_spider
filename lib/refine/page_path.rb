# -*- coding: UTF-8 -*-

module Refine
  class PagePath

    include Utility::Pattern

    attr_accessor :selectors

    def initialize(name, pattern)
      init(name, pattern)
      self.selectors = []
    end

    def match(url)
      if url.to_s =~ self.pattern
        self.selectors.each { |selector| yield selector }
      end
    end
  end
end
