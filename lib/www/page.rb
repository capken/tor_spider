# -*- coding: UTF-8 -*-

module WWW
  class Page

    GOOD_PAGE_CONTENT = /text\/(?:html|xml|json)/i

    attr_reader :code, :content_type, :body, :url, :origin

    def initialize(opts ={})
      @code = opts[:code]
      @content_type = opts[:content_type]
      @body = opts[:body]
      @url = opts[:url]
      @origin = opts[:origin]
    end

    def self.error_page(url, code)
      Page.new :code => code, :url => url.to_s, :origin => :system
    end

    def self.not_found(url)
      Page.new :code => 404, :url => url.to_s, :origin => :system
    end

    def self.bad_page(url, type)
      Page.new :content_type => type, :url => url.to_s, :origin => nil
    end

    def self.from_s3_object(obj)
      data = Zlib::Inflate.inflate(obj.value)
      build_page(
        data,
        obj.content_type,
        obj.metadata[:encoding],
        obj.metadata[:url],
        :s3
      )
    end

    def self.from_response(res)
      build_page(
        res.body_str,
        res.content_type,
        res.encoding,
        res.url,
        :web
      )
    end

    def self.build_page(data, content_type, encoding, url, origin)
      return bad_page(url, content_type) if content_type !~ GOOD_PAGE_CONTENT

      body, charset = data, encoding
      if charset !~ /utf-8/i
        body = body.force_encoding charset
        body = body.encode("utf-8", charset,
            {:undef=>:replace, :invalid=>:replace})
      end

      Page.new(
        :code => 200,
        :content_type => content_type,
        :body => body,
        :url => url,
        :origin => origin
      )
    end
  end
end
