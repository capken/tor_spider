require "rubygems"
require "bundler/setup"

require "curb"
require "uri"
require "aws/s3"
require "public_suffix"
require "digest/md5"
require "nokogiri"
require "json"
require "zlib"

CODE_ROOT = File.expand_path(File.dirname(__FILE__)) + '/../' unless defined? CODE_ROOT

%w[tor www s3 log utility refine rule].each do |dir|
  Dir.glob(CODE_ROOT + "lib/#{dir}/*.rb").each do |libname|
    warn "loading ==> #{libname}"
    require libname
  end
end

AWS::S3::Base.establish_connection!(
  :access_key_id => ENV["AWS_ACCESS_KEY_ID"],
  :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"]
)

