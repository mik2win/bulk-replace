# frozen_string_literal: true

require 'pathname'

module BulkReplace
  class DirectoryWalker
    def initialize(input_dir)
      @root = Pathname.new(input_dir)
    end

    def each_file(&block)
      @root.glob('**/*').select(&:file?).each do |path|
        block.call(path.relative_path_from(@root), path)
      end
    end
  end
end
