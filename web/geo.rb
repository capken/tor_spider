# -*- coding: UTF-8 -*-

require 'sinatra'
require 'haml'
require 'json'
require 'curb'
require 'uri'
require "bson"
require 'mongo'

include Mongo

@client = MongoClient.new('localhost', 27017)
@db     = @client['geo_db']
@coll   = @db['starbucks']

set :starbucks, @coll

USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:17.0) Gecko/17.0 Firefox/17.0"
MAP_API_KEY = "AIzaSyA1l3GrctMRBhHg7V1htQvP_3_b5jggUuY"
GEO_URL = "http://maps.googleapis.com/maps/api/geocode/json"
PLACE_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"

get '/' do
  obj = settings.starbucks.find_one({"resolve" => "no"})
  @total = settings.starbucks.find({"resolve" => "no"}).count
  if obj
    record = JSON[obj["record"]]
    @id = obj["_id"].to_s
    @payload, @payloadRaw, @meta = record['payload'], record['payloadRaw'], record['meta']
    haml :index
  else
    "No Record for GEO Resolve"
  end
end

get '/dump' do
  res = []
  settings.starbucks.find.each do |doc|
    record = {}

    raw = JSON[doc["record"]]["payloadRaw"]
    raw.each do |k, v|
      record[k] = v
    end

    meta = JSON[doc["record"]]["meta"]
    meta.each do |k, v|
      record[k] = v
    end

    res << record
  end

  content_type :json
  return res.join "\n"
end

get '/update' do
  id = params["id"]
  location = params["location"]
  lat, lng = location.split ","

  address = params["resolve_address"];

  obj = settings.starbucks.find_one({"_id" => BSON::ObjectId(id) })
  if obj
    record = JSON[obj["record"]]
    record["payloadRaw"]["lat"] = lat
    record["payloadRaw"]["lng"] = lng
    record["payloadRaw"]["map_address"] = address if address && !address.empty?

    obj["record"] = record.to_json
    obj["resolve"] = "yes"
    settings.starbucks.update({"_id" => BSON::ObjectId(id)}, obj)
  end

  redirect "/"
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
  warn curl.url
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
  geo_name = params["geo_name"]

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
    :name => URI.encode(geo_name),
    :sensor => false,
    :key => MAP_API_KEY
  }

  curl.url = "#{PLACE_URL}?#{opts.map {|k,v| "#{k}=#{v}" }.join("&")}"
  warn curl.url
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
