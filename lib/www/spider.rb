# -*- coding: UTF-8 -*-

module WWW
  class Spider

    def self.cache_read(s3_root)
      Spider.new :s3_root => s3_root, :cache_read => true
    end

    def self.crawl_only(s3_root)
      Spider.new :s3_root => s3_root, :web_crawl => true
    end

    def self.default(s3_root)
      Spider.new :s3_root => s3_root, :cache_read => true, :cache_write => true, :web_crawl => true
    end

    def initialize(opts = {})
      @cache_read = opts[:cache_read] || false
      @cache_write = opts[:cache_write] || false
      @needs_crawl = opts[:web_crawl] || false

      @proxy = opts[:proxy] || false

      @crawler = WWW::Crawler.new :proxy => @proxy
      @s3_cache = S3::Cache.new opts[:s3_root]
    end

    def crawl(url)
      obj = @s3_cache.get url if @cache_read

      if obj
        yield WWW::Page.from_s3_object(obj)
      elsif @needs_crawl
        res = @crawler.get url
        case res.code.to_s
        when /200/
          @s3_cache.put(
            url,
            res.body_str,
            :content_type => res.content_type,
            :encoding => res.encoding
          ) if @cache_write

          yield WWW::Page.from_response(res)
        when /404/
          yield WWW::Page.not_found(url)
        else
          yield WWW::Page.error_page(url, code)
          warn "#{res.code}:#{res.error}:#{url}"
        end
      else
        yield WWW:Page.not_found(url)
      end
    end

  end
end
