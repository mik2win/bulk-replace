# frozen_string_literal: true

module BulkReplace
  class FileProcessor
    def initialize(replacements)
      @replacements = replacements
    end

    def process(content)
      @replacements.reduce(content) { |text, r| text.gsub(r.from, r.to) }
    end
  end
end
