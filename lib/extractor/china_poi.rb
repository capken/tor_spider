# -*- coding: UTF-8 -*-

module Extractor
  class ChinaPOI

    def extract(input)
      output = {}

      # name
      name = input["name"]

      brand_name = input["brand_name"]
      name = "#{brand_name}-#{name}" if brand_name
      output["name"] = name

      tel = input["tel"]
      output["tel"] = tel

      output["city"] = city(input, :prefer => [:address])

      ["_source", "_date"].each { |attr| output[attr] = input[attr] }

      return output
    end

    def city(input, labels = {})
    end

  end
end
