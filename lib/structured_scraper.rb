# frozen_string_literal: true

require_relative "structured_scraper/version"
require 'nokogiri'

module StructuredScraper
  class Error < StandardError; end

  class Scraper
    def initialize(html)
      @result = {}
      @stack = []
      @parser_context = Nokogiri::HTML(html)
    end

    def evaluate_in_parser_context(parser_context, &blk)
      @parser_context = parser_context

      @stack.push(@result)

      @result = {}
      blk.call
      value = @result

      @result = @stack.pop
      value
    end

    def method_missing(name, *args, &blk)
      selector = args[0]
      selection_method = [:css, :xpath].include?(args[1]) ? args[1] : :css

      if block_given?
        @stack.push(@parser_context)

        @result[name] = []

        @parser_context.send(selection_method, selector).each do |new_parser_context|
          dict = evaluate_in_parser_context(new_parser_context, &blk)
          @result[name].push(dict)
        end

        @result[name] = @result[name].first if @result[name].length == 1

        @parser_context = @stack.pop
      else
        result_type = args[2]

        target = @parser_context.send(selection_method, selector)

        if result_type.is_a?(Array)
          @result[name] = target.map { |entry| entry&.text&.split&.join(' ') }
        else
          @result[name] = target&.text&.split&.join(' ')
        end
      end
    end

    def scrape(&blk)
      instance_eval(&blk)
      @result
    end

    def self.method_missing(name, *args, &blk)
      if block_given?
        define_singleton_method name do |html|
          Scraper.new(html).scrape(&blk)
        end
      else
        super
      end
    end

  end
end
