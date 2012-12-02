module WWW
  class Response
    attr_accessor :code, :url, :error
    attr_accessor :body_str, :content_type, :encoding

    def initialize(opts = {})
      @code = opts[:code]
      @url = opts[:url]
      @error = opts[:error]
      @body_str = opts[:body_str]
      @content_type = opts[:content_type]
      @encoding = opts[:encoding]
    end
  end
end
