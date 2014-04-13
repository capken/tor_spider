# -*- coding: UTF-8 -*-

module Rule
  class Haitao < Refine::HTMLExtractor
    domain "123haitao.com"

    page_path :details_page, /\/t\/\d+$/i

    selector :section, "div.aw-product-detail-content", :details_page
    attribute :name, "h1", :section
    attribute :date, /发表于 : ([\d\s:-]+)/i, :section, :full_doc => true
    attribute :shop_page_url, "a.buy/@href", :section, :full_doc => true

    def post_extractor(record)
      record[:name] = record[:name].gsub(/ +$/, '')
      url = record[:shop_page_url]
      record[:shop_page_url] = WWW::URLRedirection.parse url
    end

  end
end
