module Utility
  class WordList

    class State
      attr_accessor :previous, :next, :failed
      attr_accessor :words, :value, :id

      def initialize(id)
        @id, @next, @words = id, [], []
      end

      def move_to(symbol)
        @next.select { |s| s.value.eql? symbol }.first
      end

      def link_to(state)
        @next << state
      end

      def links
        @next.each { |state| yield state }
      end

      def add(word)
        @words << word
      end

      def isStart
        @id == 0
      end

      def to_s
        obj = {
          :id => @id,
          :value => @value,
          :words => @words,
          :next => []
        }

        obj[:failed] = @failed.id if @failed

        @next.each do |state|
          obj[:next] << state.to_s
        end

        return obj
      end

    end

    def initialize(list_file, opts = {})
      @debug = opts[:debug]
      @type = opts[:type] || :other

      @count = 0
      @start = create_new_state
      build_trie_from(list_file)
      build_failure_links

      warn @start.to_s.to_json if @debug
    end

    def create_new_state
      state = State.new @count
      @count += 1
      return state
    end

    def build_trie_from(list)
      File.open(list).each do |line|
        word = line.strip

        current = @start
        word.each_char do |char|
          state = current.move_to char

          if state.nil?
            state = create_new_state
            state.value = char
            state.previous = current
            state.failed = @start

            current.link_to state
          end

          current = state
        end

        current.add(word)
      end
    end

    def build_failure_links
      queue = []
      queue.push @start

      while queue.empty? == false do
        current = queue.shift
        current.links { |s| queue.push s }

        next if current.isStart

        previous = current.previous
        next if previous.isStart

        while true do
          previous = previous.failed
          candidate = previous.move_to current.value
          if candidate.nil?
            break if previous.isStart
          else
            current.failed = candidate
            candidate.words.each { |word| current.add word }
            break
          end
        end
      end
    end

    def within(str)
      current, next_state = @start, nil
      res = []

      str.chars.to_a.each_with_index do |char, index|
        warn "#{index} => #{char}" if @debug
        while true do
          next_state = current.move_to char
          break if next_state or current.isStart
          current = current.failed
        end

        if next_state
          current = next_state
          current.words.each do |word|
            entity = OpenStruct.new(
              :begin => index - word.length + 1,
              :end => index,
              :value => word,
              :type => @type
            )
            if block_given?
              yield entity
            else
              res << entity
            end
          end
        end
      end

      return res
    end
  end
end
