# -*- coding: UTF-8 -*-

module Rule
  class AjisenExtractor < Refine::HTMLExtractor

    domain "http://www.ajisen.com.cn"

    page_path :list_page, /restaurant03\.php\?cid=\d+$/i

    selector :section, /<td width="205".+?>(.+?)<\/td>/mi, :list_page

    attribute :name, "span.ajisen_heading01", :section
    attribute :tel, /电话：(.+?)</mi, :section
    attribute :address, /ajisen_txt03_gary">(.+?)</mi, :section
    attribute :city, /味千-(.+)－\d+家店门店信息/mi, :section, :full_doc => true

    tag :brand_name, "味千拉面"
  end
end
