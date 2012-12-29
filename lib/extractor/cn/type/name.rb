# -*- coding: UTF-8 -*-

module Extractor
  module Cn
    module Type
      module Name
        def extract_name(o)
          raw = o[:payloadRaw]

          name = raw["name"]
          brand = raw["brand_name"]

          o[:payload][:name] = "#{brand}-#{name}"
        end
      end
    end
  end
end
