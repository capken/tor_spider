# -*- coding: UTF-8 -*-

module Refine
  class HTMLExtractor

    attr_accessor :page_paths

    def initialize
      self.page_paths = {}

      methods = self.class.instance_methods

      methods.grep(/^page_path_/).each do |method|
        page_path = self.send method
        self.page_paths[page_path.name] = page_path
      end

      selectors = {}
      methods.grep(/^selector_/).each do |method|
        selector = self.send method
        page_path = self.page_paths[selector.page_path]
        if page_path.nil?
          raise "Page path #{selector.page_path} is not defined for selector #{selector.name}"
        else
          selectors[selector.name] = selector
          page_path.selectors << selector
        end
      end

      methods.grep(/^attribute_/).each do |method|
        attribute = self.send method
        selector = selectors[attribute.selector]
        if selector.nil?
          raise "Selector #{attribute.selector} is not defined for attribute #{attribute.name}"
        else
          selector.attributes << attribute
        end
      end

      selectors.clear
    end

    def extract(url, body)
      self.page_paths.values.each do |page_path|
        page_path.match(url) do |selector|
          selector.match(body) do |record|
            record[:_source] = url.to_s
            record[:_date] = Time.now.to_s
            yield record
          end
        end
      end
    end

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

      def selector(name, pattern, page_path)
        define_method("selector_#{name}") do
          Selector.new name, pattern, page_path
        end
      end

      def attribute(name, pattern, selector)
        define_method("attribute_#{name}") do
          Attribute.new name, pattern, selector
        end
      end
    end

  end
end
