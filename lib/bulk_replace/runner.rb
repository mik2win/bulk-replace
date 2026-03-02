# frozen_string_literal: true

require 'pathname'
require_relative 'directory_walker'
require_relative 'file_processor'

module BulkReplace
  class Runner
    def initialize(input_dir:, output_dir:, replacements:)
      @walker    = DirectoryWalker.new(input_dir)
      @processor = FileProcessor.new(replacements)
      @output    = Pathname.new(output_dir)
    end

    def run
      @walker.each_file { |rel, abs| write(rel, @processor.process(abs.read)) }
    end

    private

    def write(relative_path, content)
      dest = @output.join(relative_path)
      dest.dirname.mkpath
      dest.write(content)
    end
  end
end
