require 'spec_helper'

class FooBar; end

describe ArLookups::BaseExt do
  let(:lookup_relation) { mock_model('Dummy', pluck: []) }
  let(:lookup) do
    mock_model('Lookup', where: lookup_relation)
  end

  let(:client_class) do
    @class = Class.new
    @class.class_eval do
      def write_attribute(column, val)
        unless respond_to?(column)
          class_eval <<-RUBY, __FILE__, __LINE__+1
            attr_accessor :#{column}
          RUBY
        end

        instance_variable_set("@#{column}".to_sym, val)
      end

      def read_attribute(column)
        instance_variable_get("@#{column}".to_sym)
      end
    end

    @class.send(:extend, ArLookups::BaseExt)
    @class.lookup :foo, lookup
    @class
  end

  subject { client_class.new }

  it 'fetches values with keys' do
    expect(lookup).to receive(:where).with('key IN (?)', [1])
    expect(lookup_relation).to receive(:pluck).with(:key, :name)

    subject.foo = [1]
    subject.foo
  end

  it 'fetches values with different key name' do
    client_class.lookup :bar, lookup, key_column: :id, name_column: :place
    expect(lookup).to receive(:where).with('id IN (?)', [1])
    expect(lookup_relation).to receive(:pluck).with(:id, :place)

    subject.bar = [1]
    subject.bar
  end

  it 'returns ids from lookup' do
    subject.foo = [1,2]
    expect(subject.foo_ids).to eq([1,2])
  end

  it 'returns an empty hash if ar_lookups empty' do
    expect(subject.foo).to eq({})
  end

  it 'returns a hash' do
    subject.foo = [1,2]
    expect(subject.foo).to be_kind_of(Hash)
  end

  it 'implicitly gets the model name from the column' do
    client_class.class_eval do
      lookup :foo_bars
    end

    expect(client_class.ar_lookups[:foo_bars]).to be(FooBar)
  end
end
