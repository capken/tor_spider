# -*- coding: UTF-8 -*-

module Extractor
  module Cn
    module Type
      module Address
        def extract_address(o)
          raw = o[:payloadRaw]

          address = raw["address"]
          address = address.gsub /、/, ','
          address = address.gsub /\(.+?\)/, ''
          address = address.gsub /\([^\)]+$/, ''
          address = address.gsub /邮编.+$/, ''

          res = Utility::AddressParser.instance.parse address
          res.each do |key, value|
            o[:payload][key] = value
          end
        end
      end
    end
  end
end
