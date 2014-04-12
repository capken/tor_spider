# -*- coding: UTF-8 -*-

module Rule
  class SmzdmExtractor < Refine::HTMLExtractor
    domain "haitao.smzdm.com"

    page_path :details_page, /youhui\/\d+$/i

    selector :section, "div#left_side", :details_page
    attribute :name, "h1.con_title", :section
    attribute :date, /datePublished" content="([\d:\s-]+)"/i, :section
    attribute :shop_page_url, /(http:\/\/haitao\.smzdm\.com\/go\/\d+)/i, :section
  end
end
