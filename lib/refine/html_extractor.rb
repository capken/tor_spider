# -*- coding: UTF-8 -*-

module Refine
  class HTMLExtractor < Base

    class << self
      protected

      def selector(name, pattern, page_path, opts = {})
        define_method("selector_#{name}") do
          Selector.new name, pattern, page_path, opts
        end
      end

      def attribute(name, pattern, selector, opts = {})
        define_method("attribute_#{name}") do
          Attribute.new name, pattern, selector, opts
        end
      end
    end

    def initialize
      super

      selectors = {}
      self.methods.grep(/^selector_/).each do |method|
        selector = self.send method
        page_path = @page_paths[selector.page_path]
        if page_path.nil?
          raise "Page path #{selector.page_path} is not defined for selector #{selector.name}"
        else
          selectors[selector.name] = selector
          page_path.selectors << selector
        end
      end

      self.methods.grep(/^attribute_/).each do |method|
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
            base_append(record, url)
            yield record
          end
        end
      end
    end

  end
end
