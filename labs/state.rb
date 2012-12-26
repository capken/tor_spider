#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-

require File.expand_path(File.dirname(__FILE__)) + "/../config/load"


class AddressParser
  module State

    def initialize(parser)
      @parser = parser
    end

  end

  class Start
    include State

    def go_to(word)
      @parser.list_match word, :province, :city, :county
    end
  end

  class Province
    include State

    def go_to(word)
      @parser.list_match word, :city, :county
    end
  end

  class City
    include State

    def go_to(word)
      next_state = @parser.list_match word, :county
      return next_state if next_state

      if Street.match word
        @parser.result << { :value => word, :type => :street }
        return :street
      end

      return nil
    end
  end

  class County
    include State

    def go_to(word)
      if Street.match word
        @parser.result << { :value => word, :type => :street }
        return :street
      end

      return nil
    end
  end

  class Street
    include State

    def self.match(value)
      value =~ /^[[\u4e00-\u9fa5]]{2,8}[路街道弄]$/
    end

    def go_to(word)
      if Street.match word
        @parser.result << { :value => word, :type => :street }
        return :street
      elsif StreetNumber.match word
        @parser.result << { :value => word, :type => :street_number }
        return :street_number
      end
    end
  end

  class StreetNumber
    include State

    def self.match(value)
      value =~ /[0-9一二三四五六七八九十][号#]$/
    end

    def go_to(word)
      return nil
    end
  end

  attr_accessor :result

  def initialize
    @word_lists = {
      :province => Utility::WordList.new(
          File.join(CODE_ROOT, "lib/extractor/cn/type/provinces.txt"),
          :type => :province),
      :city => Utility::WordList.new(
          File.join(CODE_ROOT, "lib/extractor/cn/type/cities.txt"),
          :type => :city),
      :county => Utility::WordList.new(
          File.join(CODE_ROOT, "lib/extractor/cn/type/raw_counties.txt"),
          :type => :county)
    }

    @states = {}
    @states[:start] = Start.new self
    @states[:province] = Province.new self
    @states[:city] = City.new self
    @states[:county] = County.new self
    @states[:street] = Street.new self
    @states[:street_number] = StreetNumber.new self
  end

  def parse(str)
    @state, @result = @states[:start], []

    word = ""
    str.each_char do |char|
      word << char
      next_state = @state.go_to word
#      warn "#{word} ==> #{@result.to_json}"
      next if next_state.nil?

      @state = @states[next_state]
      word = ""
    end

    @result << { :value => word, :type => :other } if word.size > 0

    return post_parsing
  end

  def post_parsing
    @result.each_with_index do |cur, index|
      pre = @result[index - 1]
      next if pre.nil?

      if cur[:value] =~ /^[省市]$/
        pre[:value] = pre[:value] + cur[:value]
        cur[:value] = ""
      elsif cur[:type] != :county and cur[:value] =~ /^([省市])(.+)$/
        pre[:value] = pre[:value] + $1
        cur[:value] = $2
      end
    end.reject do |cur|
      cur[:value].empty?
    end
  end

  def list_match(word, *lists)
    next_state = nil

    lists.each do |list|
      entity = match(list, word).first
      next if entity.nil?

      @result << { :value => word[0, entity.begin], :type => :other } if entity.begin > 0
      @result << { :value => entity.value, :type => entity.type }

      next_state = list
      break
    end

    return next_state
  end

  def match(list, word)
    return @word_lists[list].within word
  end

end


ap = AddressParser.new

STDIN.each do |line|
  str = line.strip
  puts str
  res = ap.parse(str)

  puts res

  puts "="*30
end

