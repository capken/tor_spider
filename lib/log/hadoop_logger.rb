# -*- coding: UTF-8 -*-

module Log
  class HadoopReporter
    def initialize(opts = {})
      @job = opts[:job_name]
    end

    def count(type)
      warn "reporter:counter:#{@job},#{type},1"
    end

  end
end
