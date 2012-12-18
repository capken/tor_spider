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
      res = {
        :payload => {},
        :payloadRaw => {},
        :meta => {}
      }

      res[:meta][:source] = o["_source"]
      res[:meta][:date] = o["_date"]

      o.each do |key, value|
        res[:payloadRaw][key] = value unless key =~ /^_(?:date|source)$/
      end

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
