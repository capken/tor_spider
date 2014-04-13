# -*- coding: UTF-8 -*-

module Rule
  class Mgpyh < Refine::HTMLExtractor
    domain "mgpyh.com"

    page_path :details_page, /\/recommend\/.+$/i

    selector :section, "div.content", :details_page
    attribute :name, "h1.title > a", :section
    attribute :date, "div.time > span", :section, :full_doc => true
    attribute :shop_page_url, "a.btn-danger/@href", :section

    def post_extractor(record)
      now = Time.now
      date = case record[:date]
      when /(\d+)小时前/
        now - $1.to_i * 3600
      when /(\d+)天前/
        now - $1.to_i * 3600 * 24
      when /(\d+)个月前/
        now - $1.to_i * 3600 * 24 * 30
      end
      record[:date] = date.to_s

      url = "http://www." + domain + record[:shop_page_url]
      record[:shop_page_url] = WWW::URLRedirection.parse url
    end

  end
end
