# -*- coding: UTF-8 -*-

module Rule
  class PizzahutExtractor < Refine::HTMLExtractor
    domain "www.pizzahut.com.cn"

    page_path :list_pages, /GetHappyStore\.aspx\?cityid=\d+/i

    selector :item, "//item", :list_pages, :node => true
    attribute :name, "@name", :item
    attribute :address, "@address", :item
    attribute :tel, "@tel", :item

    tag :brand_name, "必胜客"
  end
end
