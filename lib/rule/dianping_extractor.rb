# -*- coding: UTF-8 -*-

module Rule
  class DianpingExtractor < Refine::HTMLExtractor
    domain "www.dianping.com"

    page_path :details_page, /shop\/\d+$/i

    selector :section, "div.section", :details_page
    attribute :name, "h1.shop-title", :section
    attribute :price, /<span class="Price">¥<\/span>\s*(\d+?)\s*<\/dd>/i, :section
    attribute :city, "a#G_loc > span", :section, :full_doc => true
    attribute :district, "span[@itemprop='locality region']", :section
    attribute :street_address, "span[@itemprop='street-address']", :section
    attribute :tel, "strong[@itemprop='tel']", :section
  end
end
