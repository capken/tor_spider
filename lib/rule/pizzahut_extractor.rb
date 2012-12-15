# -*- coding: UTF-8 -*-

module Rule
  class PizzahutExtractor < Refine::HTMLExtractor
    domain "http://www.pizzahut.com.cn/"

    page_path :list_xml, /GetHappyStore\.aspx\?cityid=\d+/i

    selector :item, "//item", :list_xml
    attribute :name, /name="(.+?)"/, :item

    tag :brand_name, "必胜客"
  end
end
