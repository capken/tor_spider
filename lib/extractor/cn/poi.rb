# -*- coding: UTF-8 -*-

module Extractor
  module Cn
    class POI < Base
      include Type::Tel

      order :tel
    end
  end
end
