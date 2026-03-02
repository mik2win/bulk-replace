# frozen_string_literal: true

RSpec.describe BulkReplace::Runner do
  let(:replacement) { BulkReplace::Replacement.new(from: 'OLD', to: 'NEW') }

  around do |example|
    Dir.mktmpdir do |input|
      Dir.mktmpdir do |output|
        @input  = input
        @output = output
        example.run
      end
    end
  end

  def create_input(relative_path, content)
    full = File.join(@input, relative_path)
    FileUtils.mkdir_p(File.dirname(full))
    File.write(full, content)
  end

  def read_output(relative_path)
    File.read(File.join(@output, relative_path))
  end

  describe '#run' do
    it 'processes a flat file and writes it to the output directory' do
      create_input('wg0.conf', 'DNS = OLD')
      described_class.new(input_dir: @input, output_dir: @output, replacements: [replacement]).run
      expect(read_output('wg0.conf')).to eq('DNS = NEW')
    end

    it 'preserves subdirectory structure in output' do
      create_input('sub/wg1.conf', 'OLD')
      described_class.new(input_dir: @input, output_dir: @output, replacements: [replacement]).run
      expect(read_output('sub/wg1.conf')).to eq('NEW')
    end

    it 'creates output subdirectories automatically' do
      create_input('a/b/c.conf', 'OLD')
      described_class.new(input_dir: @input, output_dir: @output, replacements: [replacement]).run
      expect(File).to exist(File.join(@output, 'a/b/c.conf'))
    end

    it 'does nothing when input directory is empty' do
      described_class.new(input_dir: @input, output_dir: @output, replacements: [replacement]).run
      expect(Dir.glob(File.join(@output, '**/*'))).to be_empty
    end
  end
end
