# -*- coding: UTF-8 -*-

module Rule
  class PapajohnsExtractor < Refine::HTMLExtractor
    domain "www.papajohnschina.com"

    page_path :list_page, /info_search\.php\?cit=.+$/i

    selector :section, ".pizzas_list_dre ul", :list_page
    attribute :name, /class="wid96">(.+?)</mi, :section
    attribute :address, /class="wid289">(.+?)</mi, :section
    attribute :tel, /订餐电话：([\d-]+)/mi, :section
  end
end
