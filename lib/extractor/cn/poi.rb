# -*- coding: UTF-8 -*-

module Extractor
  module Cn
    class POI < Base
      include Type::Name
      include Type::Tel
      include Type::Address

      order :name, :tel, :address
    end
  end
end
