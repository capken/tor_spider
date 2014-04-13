# -*- coding: UTF-8 -*-

module WWW
  class URLRedirection

    def self.parse(url, type = :header)
      case type
      when :header
        res = `curl -s -I "#{url}"`
        if res =~ /Location:\s*(.+)\s*$/
          return $1.strip
        end
      end
    end
  end
end
