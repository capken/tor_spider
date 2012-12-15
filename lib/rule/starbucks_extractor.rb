# -*- coding: UTF-8 -*-

module Rule
  class StarbucksExtractor < Refine::HTMLExtractor
    domain "www.starbucks.com.cn"

    page_path :detail_pages, /store\/.+?\.html$/i

    selector :section, "div#address_detail", :detail_pages
    attribute :name, ".title span", :section
    attribute :address, /门店地址：<\/li>\s*<li class="large">(.+?)<\/li>/mi, :section
    attribute :tel, /联系电话：<\/li>\s*<li class="large">(.+?)<\/li>/mi, :section

    tag :brand_name, "星巴克"
  end
end
