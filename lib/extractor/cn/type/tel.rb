# -*- coding: UTF-8 -*-

module Extractor
  module Cn
    module Type
      module Tel
        def extract_tel(o)
          raw = o[:payloadRaw]

          tel = raw["tel"]

          tel = tel.gsub /[^0-9-]/, ""

          o[:payload][:tel] = tel
        end
      end
    end
  end
end
