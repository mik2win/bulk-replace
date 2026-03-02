# frozen_string_literal: true

RSpec.describe BulkReplace::Replacement do
  subject(:replacement) { described_class.new(from: 'old', to: 'new') }

  it 'stores from and to' do
    expect(replacement.from).to eq('old')
    expect(replacement.to).to eq('new')
  end

  it 'is frozen' do
    expect(replacement).to be_frozen
  end

  it 'has value equality' do
    other = described_class.new(from: 'old', to: 'new')
    expect(replacement).to eq(other)
  end
end
