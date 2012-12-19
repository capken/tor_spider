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

      res[:meta][:source] = o.delete "_source"
      res[:meta][:date] = o.delete "_date"

      o.each { |k, v| res[:payloadRaw][k] = v }

      return res
    end

    class << self

      protected

      def order(*params)
        define_method(:attributes) { return params }
      end
    end

    private

    def match(str, pattern)
      return nil if pattern.nil?

      if pattern =~ /\[\[(.+?)\]\]/
        list = $1
      else
        return nil
      end
    end

    def within(str, list)
    end
  end
end
