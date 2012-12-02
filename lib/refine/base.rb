# -*- coding: UTF-8 -*-

module Refine
  class Base
  end
end


#Refine::HTMLExtractor.new("dianping.com") do
#  url_path /shop\/[\d+]$/ do |path|
#    on_selector "div.section" do |selector|
#      key :name, "h1.shop-title"
#    end
#  end
#end

#
#class GoogleGeoAPI < Refine::JSONExtractor
#  domain "maps.googleapis.com"
#  url_path :geocode, :pattern => /maps\/api\/geocode\/json/
#  selector :result, :pattern => "results", :path => :geocode
#  key :lat, :pattern => "geometry/location/lat", :selector => :result
#  key :lng, :pattern => "geometry/location/lng", :selector => :result
#end
