# frozen_string_literal: true

require 'optparse'
require_relative 'replacement_set'
require_relative 'runner'

module BulkReplace
  class CLI
    def initialize(argv)
      @argv    = argv
      @options = {}
    end

    def run
      parser.parse!(@argv)
      validate!
      Runner.new(
        input_dir: @options[:input],
        output_dir: @options[:output],
        replacements: replacements
      ).run
    end

    private

    def parser
      OptionParser.new do |o|
        o.on('--from FROM', 'String to replace')   { |v| @options[:from]   = v }
        o.on('--to TO',     'Replacement string')  { |v| @options[:to]     = v }
        o.on('--config PATH', 'YAML config file')  { |v| @options[:config] = v }
        o.on('--input DIR',  'Input directory')    { |v| @options[:input]  = v }
        o.on('--output DIR', 'Output directory')   { |v| @options[:output] = v }
      end
    end

    def validate!
      raise ArgumentError, '--input is required'  unless @options[:input]
      raise ArgumentError, '--output is required' unless @options[:output]
      raise ArgumentError, 'provide --config or both --from and --to' unless valid_mode?
    end

    def valid_mode?
      @options[:config] || (@options[:from] && @options[:to])
    end

    def replacements
      if @options[:config]
        ReplacementSet.from_config(@options[:config])
      else
        ReplacementSet.from_inline(from: @options[:from], to: @options[:to])
      end
    end
  end
end
