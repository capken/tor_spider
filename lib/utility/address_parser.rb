# -*- coding: UTF-8 -*-

module Utility
  class AddressParser
  
    def initialize
      setup_words_list
      setup_state_machine
    end
  
    def setup_words_list
      @word_lists = {}
      [:province, :city, :county].each do |list_name|
        @word_lists[:list_name] = Utility::WordList.new(
          File.join(CODE_ROOT, "lib/extractor/cn/type/#{list_name}.txt"),
          :type => list_name
        )
      end
    end
  
    def setup_state_machine
      @states = {}
      [Start, Province, City, County, Area,
        Street, StreetNumber, Landmark].each do |state|
        @states[state.to_s.downcase.to_sym] = state.new(self)
      end
    end
  
    def move_to(state)
      if state.nil?
        return false
      else
        @state = @states[state]
        return true
      end
    end
  
    def reset_state_machine
      @state, @result = @states[:start], []
    end
  
    def current_state
      @state
    end
  
    def handle_tail(word)
      @result << { :value => word, :type => :other } if word.size > 0
      return self
    end
  
    def each_entity_pair
      @result.each_with_index do |cur, index|
        pre = @result[index - 1]
        next if pre.nil?
  
        yield cur, pre
      end
    end
  
    def post_parsing
      [Privince, City, County, Street,
        StreetNumber, Landmark].each do |state|
        each_entity_pair do |cur, pre|
          state.revise cur, pre
        end
      end
  
      each_entity_pair do |cur, pre|
        if cur[:type] == :street && pre[:type] == :street
          cur[:value] = pre[:value] + cur[:value]
          pre[:value] = ""
        end
      end
  
      @results.reject { |entity| entity[:value].empty? }
  
      return self
    end
  
    def format
      obj = {}
      [:province, :city, :county, :area, :street,
        :streetnumber, :landmark, :other].each do |att|
        @result.each do |cur|
          obj[att] = cur[:value] if cur[:type] == att
        end
      end
  
      return obj.to_json
    end
  
    def parse(str)
      reset_state_machine
  
      word = ""
      str.each_char do |char|
        word << char
        next_state = current_state.link_to word
        word = "" if move_to(next_state)
      end
  
      return handle_tail(word).post_parsing.format
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
  
    ##### states definition for Chinese address module #####
  
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
  
      def link_to(word)
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
  
      def link_to(word)
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
  
      def link_to(word)
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
        if cur[:value] =~ /^([省市区])(.+)$/ && pre[:value].last != $1
          pre[:value] = pre[:value] + $1
          cur[:value] = $2
        end
      end
  
      def link_to(word)
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
  
      def link_to(word)
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
        if cv =~ /^([0-9一二三四五六七八东西南北中]+[路段])(.+$)/ && pre[:type] == :street
          pre[:value] = pv + $1
          cur[:value] = $2
        elsif cv.first =~ /^道(.+)/ && pv.last =~ /街/
          pre[:value] = pv + "道"
          cur[:value] = $1
        elsif cv =~ /^交汇处(.+)/ && pre[:type] == :street
          cur[:value] = $1
        elsif cv =~ /^与(.+)/ && cur[:type] == :street && pre[:type] == :street
          cur[:value] = $1
        end
      end
  
      def self.match(value)
        value =~ /^[\u4e00-\u9fa5]{2,8}[路街道弄]|^[\u4e00-\u9fa5]{2,8}[东南西北]里$/
      end
  
      def link_to(word)
        if Street.match word
          return new_state(:street, word)
        elsif StreetNumber.match word
          return new_state(:streetnumber, word)
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
        value =~ /^.{,3}[0-9一二三四五六七八九十甲乙丙丁,-]+[弄号#]$/
      end
  
      def self.revise(cur, pre)
        if cur[:value] =~ /^([院楼])(.+)$/ && pre[:type] == :streetnumber
          pre[:value] = pre[:value] + $1
          cur[:value] = $2
        end
      end
  
      def link_to(word)
        if Landmark.match word
          return new_state(:landmark, word)
        else
          return nil
        end
      end
    end
  
    class Landmark
      include State
  
      POSTFIX = "(?:电子城|市场|百货|花园|书城|广场|大楼|大厦|机场|商城|商业街|商业水城|酒吧街|中心|影城|国际商区|大酒店|大学)"
  
      def self.revise(cur, pre)
        if pre[:value] =~ /^#{POSTFIX}$/ && pre[:type] == :landmark
          cur[:value] = pre[:value] + cur[:value]
          pre[:value] = ""
        end
      end
  
      def self.match(value)
        value =~ /^[\u4e00-\u9fa5]{2,9}#{POSTFIX}$/
      end
  
      def link_to(word)
        return nil
      end
    end
  end
end
