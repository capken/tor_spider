# -*- coding: UTF-8 -*-

module Refine
  class Base

    attr_accessor :page_paths

    def initialize
      @page_paths = {}
      self.methods.grep(/^page_path_/).each do |method|
        page_path = self.send method
        @page_paths[page_path.name] = page_path
      end
    end

    def add_tags(record)
      self.methods.grep(/^tag_/).each do |method|
        key = method.to_s.gsub /^tag_/, ""
        value = self.send method

        record[key] = value
      end
    end

    def base_append(record, url)
      record[:_source] = url.to_s
      record[:_date] = Time.now.to_s
      add_tags record
      post_extractor record
    end

    protected

    class << self
      protected

      def domain(value)
        define_method(:domain) { return value }
      end

      def page_path(name, pattern)
        define_method("page_path_#{name}") do
          PagePath.new name, pattern
        end
      end

      def tag(key, value)
        define_method("tag_#{key}") do
          value
        end
      end
    end
  end
end
