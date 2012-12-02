# -*- coding: UTF-8 -*-

module WWW
  class Url

    attr_reader :domain, :md5

    def initialize(url_str)
      raise "Bad URL: #{url_str}" if url_str !~ URI::ABS_URI
      @url_str = url_str
      @md5 = Digest::MD5.hexdigest(@url_str)
      @uri = URI.parse @url_str
      @domain = PublicSuffix.parse(@uri.host).domain
    end

    def host
      @uri.host
    end

    def to_s
      @url_str
    end

  end
end
