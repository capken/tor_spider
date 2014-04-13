# -*- coding: UTF-8 -*-

module WWW
  class URLNormalizer

    def self.format(url)
      url = WWW::URL.new url
      case url.domain
      when /amazon\.com/
        if url.to_s =~ /\/(?:gp\/product|dp)\/([A-Z0-9]{10})/
          return "http://www.amazon.com/dp/#{$1}"
        end
      end

      url.to_s
    end
  end
end
