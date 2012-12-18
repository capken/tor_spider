# -*- coding: UTF-8 -*-

module Extractor
  module China
    class POI < Extractor::Base
      include Tel

      order :tel
    end
  end
end
