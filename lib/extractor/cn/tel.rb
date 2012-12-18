# -*- coding: UTF-8 -*-

module Extractor
  module China
    module Tel
      def extract_tel(o)
        raw = o["raw"]
        tel = raw["tel"]
        o["tel"] = tel
      end
    end
  end
end
