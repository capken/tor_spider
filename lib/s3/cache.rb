# -*- coding: UTF-8 -*-

module S3
  class Cache
    include AWS::S3

    def initialize(root)
      @bucket = root.to_s
    end

    def get(url)
      S3Object.find(s3_path_of(url), @bucket) rescue nil
    end

    def put(url, data, meta)
      config = default_config.merge(
        :content_type => meta[:content_type],
        :content_encoding => "deflate",
        "x-amz-meta-encoding" => meta[:encoding],
        "x-amz-meta-url" => url.to_s,
      )

      compressed_data = Zlib::Deflate.deflate(data)

      S3Object.store(s3_path_of(url), compressed_data, @bucket, config) rescue nil
    end

    private

    def default_config
      { :access => :public_read }
    end

    def s3_path_of(url)
      "cache/#{url.domain}/#{url.md5}"
    end

  end
end
