# -*- coding: UTF-8 -*-

module Tor
  class IPHelper
    RESET_CMD = 'AUTHENTICATE "newpassword"\r\nsignal NEWNYM\r\nQUIT'

    def self.reset
      system "echo -e '#{RESET_CMD}' | nc 127.0.0.1 9051"
      sleep 3
    end
  end
end
