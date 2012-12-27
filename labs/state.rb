#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-

require File.expand_path(File.dirname(__FILE__)) + "/../config/load"

class String
  def first
    self[0]
  end

  def last
    self[self.size-1]
  end
end

class AddressParser
  module State

    def initialize(parser)
      @parser = parser
    end

    def new_state(state, word)
      @parser.result << { :value => word, :type => state }
      return state
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

    def self.revise(cur, pre)
      if cur[:value] =~ /^[省市]$/ && pre[:type] == :province
        pre[:value] = pre[:value] + cur[:value]
        cur[:value] = ""
      end
    end

    def go_to(word)
      @parser.list_match word, :city, :county
    end
  end

  class City
    include State

    def self.revise(cur, pre)
      if cur[:value] =~ /^市$/ && pre[:type] == :city
        pre[:value] = pre[:value] + cur[:value]
        cur[:value] = ""
      end
    end

    def go_to(word)
      next_state = @parser.list_match word, :county
      return next_state if next_state

      if Street.match(word)
        return new_state(:street, word)
      elsif Area.match word
        return new_state(:area, word)
      elsif Landmark.match word
        return new_state(:landmark, word)
      else
        return nil
      end
    end
  end

  class County
    include State

    def self.revise(cur, pre)
      if cur[:type] != :county && cur[:value] =~ /^([省市区]|新区)(.+)$/
        pre[:value] = pre[:value] + $1
        cur[:value] = $2
      end
    end

    def go_to(word)
      if Street.match(word)
        return new_state(:street, word)
      elsif Area.match word
        return new_state(:area, word)
      elsif Landmark.match word
        return new_state(:landmark, word)
      else
        return nil
      end
    end
  end

  class Area
    include State

    def self.match(value)
      value =~ /^[\u4e00-\u9fa5].*(?:保税区|软件园|开发区|科技园区|工业园区|新区|文化保护区|公园|商务区)$/
    end

    def go_to(word)
      if Street.match word
        return new_state(:street, word)
      elsif Landmark.match word
        return new_state(:landmark, word)
      else
        return nil
      end
    end

  end

  class Street
    include State

    def self.revise(cur, pre)
      cv, pv = cur[:value], pre[:value]
      if cv =~ /^([0-9一二三四五六七八东西南北中][路段])(.+$)/ && pre[:type] == :street
        pre[:value] = pv + $1
        cur[:value] = $2
      elsif cv.first =~ /^道(.+)/ && pv.last =~ /街/
        pre[:value] = pv + "道"
        cur[:value] = $1
      end
    end

    def self.match(value)
      value =~ /^[\u4e00-\u9fa5]{2,8}[路街道弄]|^[\u4e00-\u9fa5]{2,8}[东南西北]里$/
    end

    def go_to(word)
      if Street.match word
        return new_state(:street, word)
      elsif StreetNumber.match word
        return new_state(:street_number, word)
      elsif Landmark.match word
        return new_state(:landmark, word)
      else
        return nil
      end
    end

  end

  class StreetNumber
    include State

    def self.match(value)
      value =~ /^[0-9一二三四五六七八九十甲乙丙丁,-]+[弄号#]$/
    end

    def self.revise(cur, pre)
      if cur[:value] =~ /^([院楼])(.+$)/ && pre[:type] == :street_number
        pre[:value] = pre[:value] + $1
        cur[:value] = $2
      end
    end

    def go_to(word)
      if Landmark.match word
        return new_state(:landmark, word)
      else
        return nil
      end
    end
  end

  class Landmark
    include State

    def self.match(value)
      value =~ /^[\u4e00-\u9fa5]{2,9}(?:电子城|市场|百货|花园|书城|广场|大楼|大厦|机场|商城|商业街|商业水城|酒吧街|中心|影城|国际商区|大酒店|大学)$/
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
    @states[:area] = Area.new self
    @states[:street] = Street.new self
    @states[:street_number] = StreetNumber.new self
    @states[:landmark] = Landmark.new self
  end

  def parse(str)
    @state, @result = @states[:start], []

    str = str.gsub /－/, '-'
    str = str.gsub /、/, ','
    str = str.gsub /邮编.+$/, ''

    word = ""
    str.each_char do |char|
      word << char
      next_state = @state.go_to word
#    warn "#{word} === #{@state} ==> #{@result.to_json}"
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

      Province.revise cur, pre
      City.revise cur, pre
      County.revise cur, pre
      Street.revise cur, pre
      StreetNumber.revise cur, pre
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

