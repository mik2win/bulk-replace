# frozen_string_literal: true

RSpec.describe BulkReplace::FileProcessor do
  let(:r) { ->(from, to) { BulkReplace::Replacement.new(from: from, to: to) } }

  describe '#process' do
    it 'replaces all occurrences in the content' do
      processor = described_class.new([r.call('foo', 'bar')])
      expect(processor.process('foo and foo')).to eq('bar and bar')
    end

    it 'applies multiple replacements in order' do
      processor = described_class.new([r.call('a', 'b'), r.call('b', 'c')])
      expect(processor.process('a')).to eq('c')
    end

    it 'returns content unchanged when no match' do
      processor = described_class.new([r.call('xyz', 'abc')])
      expect(processor.process('hello world')).to eq('hello world')
    end

    it 'returns empty string for empty content' do
      processor = described_class.new([r.call('foo', 'bar')])
      expect(processor.process('')).to eq('')
    end

    it 'returns content unchanged with no replacements' do
      processor = described_class.new([])
      expect(processor.process('hello')).to eq('hello')
    end
  end
end
