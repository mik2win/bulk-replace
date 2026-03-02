# frozen_string_literal: true

RSpec.describe BulkReplace::CLI do
  around do |example|
    Dir.mktmpdir do |input|
      Dir.mktmpdir do |output|
        @input  = input
        @output = output
        example.run
      end
    end
  end

  def create_input(name, content)
    File.write(File.join(@input, name), content)
  end

  describe '#run' do
    context 'inline mode' do
      it 'replaces text using --from and --to' do
        create_input('wg0.conf', 'DNS = 8.8.8.8')
        described_class.new(['--from', '8.8.8.8', '--to', '1.1.1.1',
                             '--input', @input, '--output', @output]).run
        expect(File.read(File.join(@output, 'wg0.conf'))).to eq('DNS = 1.1.1.1')
      end
    end

    context 'config file mode' do
      it 'replaces text using a YAML config' do
        yaml = "replacements:\n  - from: \"8.8.8.8\"\n    to: \"1.1.1.1\"\n"
        config = Tempfile.new(['cfg', '.yml'])
        config.write(yaml)
        config.close

        create_input('wg0.conf', 'DNS = 8.8.8.8')
        described_class.new(['--config', config.path,
                             '--input', @input, '--output', @output]).run
        expect(File.read(File.join(@output, 'wg0.conf'))).to eq('DNS = 1.1.1.1')
      ensure
        config&.unlink
      end
    end

    context 'validation' do
      it 'raises ArgumentError when --input is missing' do
        expect do
          described_class.new(['--from', 'a', '--to', 'b', '--output', @output]).run
        end.to raise_error(ArgumentError, /--input/)
      end

      it 'raises ArgumentError when --output is missing' do
        expect do
          described_class.new(['--from', 'a', '--to', 'b', '--input', @input]).run
        end.to raise_error(ArgumentError, /--output/)
      end

      it 'raises ArgumentError when neither --config nor --from/--to provided' do
        expect do
          described_class.new(['--input', @input, '--output', @output]).run
        end.to raise_error(ArgumentError, /--config/)
      end

      it 'raises ArgumentError when --from is given without --to' do
        expect do
          described_class.new(['--from', 'a', '--input', @input, '--output', @output]).run
        end.to raise_error(ArgumentError)
      end

      it 'raises Errno::ENOENT when --config file does not exist' do
        expect do
          described_class.new(['--config', '/nonexistent/file.yml',
                               '--input', @input, '--output', @output]).run
        end.to raise_error(Errno::ENOENT)
      end
    end
  end
end
