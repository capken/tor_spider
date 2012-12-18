# -*- coding: UTF-8 -*-

module Extractor
  class Base

    def run(obj)
      obj = thrift_of(obj)
      attributes.each do |attr|
        self.send "extract_#{attr}", obj
      end

      return obj
    end

    def thrift_of(o)
      res = {}

      res[:payloadRaw] = o
      res[:payload] = {}

      return res
    end

    class << self

      protected

      def order(*params)
        define_method(:attributes) { return params }
      end
    end
  end
end
