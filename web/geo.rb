# -*- coding: UTF-8 -*-

require 'sinatra'
require 'haml'
require 'json'
require 'curb'
require 'uri'

USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:17.0) Gecko/17.0 Firefox/17.0"
MAP_API_KEY = "AIzaSyA1l3GrctMRBhHg7V1htQvP_3_b5jggUuY"
GEO_URL = "http://maps.googleapis.com/maps/api/geocode/json"
PLACE_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"

get '/' do
  s = '{"payload":{"name":"星巴克-嘉里中心咖啡店","tel":"010-85296169","province":"北京市","city":"朝阳区","street":"光华路","streetnumber":"1号","landmark":"嘉里中心","other":"首层01单元"},"payloadRaw":{"name":"嘉里中心咖啡店","address":"北京市朝阳区光华路1号嘉里中心首层01单元","tel":"010-85296169","brand_name":"星巴克"},"meta":{"source":"http://www.starbucks.com.cn/store/kerrycenter.html?region=%E5%8C%97%E4%BA%AC%E5%B8%82&locality=%E6%9C%9D%E9%98%B3%E5%8C%BA","date":"2012-12-28 14:49:33 +0800"}}'
  obj = JSON[s]
  @payload = obj['payload']
  @payloadRaw = obj['payloadRaw']
  @meta = obj['meta']
  haml :index
end

get '/geo.json' do
  address = params['address']

  curl = Curl::Easy.new do |c|
    c.follow_location = true
    c.max_redirects = 3
    c.timeout = 20
    c.connect_timeout = 10
    c.headers["User-Agent"] = USER_AGENT
    c.encoding = 'gzip,deflate'
  end

  curl.url = "#{GEO_URL}?address=#{URI.encode(address)}&sensor=true"
  curl.perform

  response = {}
  response["code"] = curl.response_code

  if curl.response_code == 200
    res = JSON[curl.body_str]
    if res["status"] == "OK"
      result = res["results"].first
      if result
        response["formatted_address"] = result["formatted_address"]
        response["lat"] = result["geometry"]["location"]["lat"]
        response["lng"] = result["geometry"]["location"]["lng"]
      end
    end
  end

  content_type :json

  return response.to_json
end

get '/revise.json' do
  lat, lng = params["lat"], params["lng"]

  curl = Curl::Easy.new do |c|
    c.follow_location = true
    c.max_redirects = 3
    c.timeout = 20
    c.connect_timeout = 10
    c.headers["User-Agent"] = USER_AGENT
    c.encoding = 'gzip,deflate'
  end

  opts = {
    :location => "#{lat},#{lng}",
    :radius => "500",
    :name => URI.encode('星巴克'),
    :sensor => false,
    :key => MAP_API_KEY
  }

  curl.url = "#{PLACE_URL}?#{opts.map {|k,v| "#{k}=#{v}" }.join("&")}"
  curl.perform

  response = { :records => [] }
  response["code"] = curl.response_code

  if curl.response_code == 200
    res = JSON[curl.body_str]
    if res["status"] == "OK"
      res["results"].each do |record|
        response[:records] << {
          :name => record["name"],
          :lat => record["geometry"]["location"]["lat"],
          :lng => record["geometry"]["location"]["lng"],
          :vicinity => record["vicinity"]
        }
      end
    end
  end

  content_type :json
  return response.to_json
end
