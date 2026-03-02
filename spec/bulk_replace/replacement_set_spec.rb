# frozen_string_literal: true

RSpec.describe BulkReplace::ReplacementSet do
  describe '.from_inline' do
    it 'returns a single Replacement in an array' do
      result = described_class.from_inline(from: 'old', to: 'new')
      expect(result).to eq([BulkReplace::Replacement.new(from: 'old', to: 'new')])
    end
  end

  describe '.from_config' do
    it 'parses a YAML file into an array of Replacements' do
      yaml = <<~YAML
        replacements:
          - from: "DNS = 8.8.8.8"
            to: "DNS = 1.1.1.1"
          - from: "PLACEHOLDER"
            to: "real_key"
      YAML

      file = Tempfile.new(['replacements', '.yml'])
      file.write(yaml)
      file.close

      result = described_class.from_config(file.path)

      expect(result.length).to eq(2)
      expect(result[0]).to eq(BulkReplace::Replacement.new(from: 'DNS = 8.8.8.8', to: 'DNS = 1.1.1.1'))
      expect(result[1]).to eq(BulkReplace::Replacement.new(from: 'PLACEHOLDER', to: 'real_key'))
    ensure
      file&.unlink
    end

    it 'raises Errno::ENOENT when file does not exist' do
      expect { described_class.from_config('/nonexistent/path.yml') }.to raise_error(Errno::ENOENT)
    end

    it 'raises Psych::SyntaxError when YAML is malformed' do
      file = Tempfile.new(['bad', '.yml'])
      file.write("replacements:\n  - from: [unclosed")
      file.close
      expect { described_class.from_config(file.path) }.to raise_error(Psych::SyntaxError)
    ensure
      file&.unlink
    end

    it "raises ArgumentError when YAML is missing 'replacements' key" do
      file = Tempfile.new(['bad', '.yml'])
      file.write("other_key: value\n")
      file.close
      expect { described_class.from_config(file.path) }.to raise_error(ArgumentError, /replacements/)
    ensure
      file&.unlink
    end

    it 'raises ArgumentError when a replacement entry is missing required keys' do
      file = Tempfile.new(['bad', '.yml'])
      file.write("replacements:\n  - from: \"old\"\n")
      file.close
      expect { described_class.from_config(file.path) }.to raise_error(ArgumentError)
    ensure
      file&.unlink
    end
  end
end
