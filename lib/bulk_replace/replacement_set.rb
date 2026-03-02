# frozen_string_literal: true

require 'yaml'
require_relative 'replacement'

module BulkReplace
  class ReplacementSet
    def self.from_config(path)
      raw = YAML.safe_load(File.read(path), symbolize_names: true)
      unless raw.is_a?(Hash) && raw[:replacements].is_a?(Array)
        raise ArgumentError,
              "Config must contain a 'replacements' key"
      end

      raw[:replacements].map { |r| Replacement.new(**r) }
    end

    def self.from_inline(from:, to:)
      [Replacement.new(from: from, to: to)]
    end
  end
end
