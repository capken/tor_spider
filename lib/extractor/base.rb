# -*- coding: UTF-8 -*-

module Extractor
  class Base

    def run(o)
      attributes.each do |attr|
        self.send "extract_#{attr}", o
      end
    end

    class << self

      protected

      def order(*params)
        define_method(:attributes) { return params }
      end
    end
  end
end
