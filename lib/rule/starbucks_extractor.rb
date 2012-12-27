# -*- coding: UTF-8 -*-

module Rule
  class StarbucksExtractor < Refine::HTMLExtractor
    domain "www.starbucks.com.cn"

    page_path :detail_pages, /store\/.+?\.html/i

    selector :section, "div#address_detail", :detail_pages
    attribute :name, ".title span", :section
    attribute :address, /门店地址：<\/li>\s*<li class="large">(.+?)<\/li>/mi, :section
    attribute :tel, /联系电话：<\/li>\s*<li class="large">(.+?)<\/li>/mi, :section

    tag :brand_name, "星巴克"

    def post_extractor(record)
      url = URI.parse record[:_source]
      params = CGI.parse url.query

      address = record[:address].gsub /^中国/, ''

      ["locality", "region"].each do |key|
        address = "#{params[key].first}#{address}"
      end

      address = address.gsub /(.{2,}?)\1/, '\1'

      record[:address] = address.gsub /[\s]+/, ''
    end
  end
end
