# -*- coding: UTF-8 -*-

module Rule
  class Taozhe < Refine::HTMLExtractor
    domain "tz100.com"

    page_path :details_page, /\/item\/\d+\/$/i

    selector :section, "div#Content_detail", :details_page
    attribute :title, "h2", :section
    attribute :date, /span>\s*(.+?)发布/i, :section
    attribute :shop_page_url, "a.btn_buy/@href", :section
  end
end
