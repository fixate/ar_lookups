require 'spec_helper'

describe ArLookups::LookupTableDefinition do
  subject do
    class TableDefinition; include ArLookups::LookupTableDefinition; end.new
  end

  it 'creates an integer array column with default' do
    expect(subject).to receive(:integer).with(:foo, {array: true, default: []})
    subject.lookup :foo
  end

  it 'creates an custom typed array column with default' do
    expect(subject).to receive(:string).with(:foo, {array: true, default: []})
    subject.lookup :foo, type: :string
  end

  it 'merges additional options in preserving array:true' do
    expect(subject).to receive(:integer).with(:foo, {test: 'foobar', array: true, default: []})
    subject.lookup :foo, test: 'foobar'
  end

  it 'uses default if given' do
    expect(subject).to receive(:integer).with(:foo, {default: [1, 2], array: true, default: []})
    subject.lookup :foo, default: [1, 2]
  end
end
