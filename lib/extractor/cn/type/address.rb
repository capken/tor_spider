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

          o[:payload][:tel] = address
        end
      end
    end
  end
end
