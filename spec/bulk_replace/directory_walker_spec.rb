# frozen_string_literal: true

RSpec.describe BulkReplace::DirectoryWalker do
  around do |example|
    Dir.mktmpdir do |dir|
      @dir = dir
      example.run
    end
  end

  def create_file(relative_path, content = '')
    full = File.join(@dir, relative_path)
    FileUtils.mkdir_p(File.dirname(full))
    File.write(full, content)
  end

  describe '#each_file' do
    it 'yields relative and absolute paths for a flat file' do
      create_file('wg0.conf', 'content')
      walker = described_class.new(@dir)
      results = []
      walker.each_file { |rel, abs| results << [rel.to_s, abs.to_s] }
      expect(results).to contain_exactly(['wg0.conf', File.join(@dir, 'wg0.conf')])
    end

    it 'recurses into subdirectories' do
      create_file('sub/wg1.conf', 'content')
      walker = described_class.new(@dir)
      relatives = []
      walker.each_file { |rel, _| relatives << rel.to_s }
      expect(relatives).to include('sub/wg1.conf')
    end

    it 'does not yield directories' do
      FileUtils.mkdir_p(File.join(@dir, 'subdir'))
      walker = described_class.new(@dir)
      results = []
      walker.each_file { |rel, _| results << rel.to_s }
      expect(results).to be_empty
    end

    it 'yields nothing for an empty directory' do
      walker = described_class.new(@dir)
      results = []
      walker.each_file { |rel, _| results << rel.to_s }
      expect(results).to be_empty
    end
  end
end
