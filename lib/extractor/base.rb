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

      o.each { |k, v| res[:payloadRaw][k] = db2sb(v) }

      return res
    end

    # convert double byte characters to single byte characters
    def db2sb(str)
      res = ""

      str.each_char do |char|
        code_num = char.codepoints.first

        if 65281 <= code_num and code_num <= 65374
          code_num = code_num - 65248
        elsif code_num == 12288
          code_num = 32
        end

        res << code_num.chr('utf-8')
      end

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
  end
end
