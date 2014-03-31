require 'byebug'
require 'spec_helper'

class FooBar; end

class Model < ActiveRecord::Base; end
#TODO: so the only way to test this properly, I think, is to make a test db :(((((
#      Ain't nobody got time for that...

$ar_count = 0
describe ArLookups::ActiveRecordExt do
  let(:lookup_relation) { mock_model('Dummy', value: 'Some Val') }
  let(:lookup) do
    mock_model('Lookup', where: lookup_relation, column_defaults: [])
  end

  let(:client_class) do
    $ar_count += 1
    @class = Class.new(Model)
    # Give the class a name for activerecord
    Object.const_set("Model#{$ar_count}", @class)
    @class.table_name = "models"

    # @class.class_eval do
    #   def write_attribute(column, val)
    #     unless respond_to?(column)
    #       class_eval <<-RUBY, __FILE__, __LINE__+1
    #         attr_accessor :#{column}
    #       RUBY
    #     end

    #     instance_variable_set("@#{column}".to_sym, val)
    #   end

    #   def read_attribute(column)
    #     instance_variable_get("@#{column}".to_sym)
    #   end
    # end

    @class.send(:extend, ArLookups::ActiveRecordExt)
    @class.lookup :foo, lookup
    @class
  end

  subject { client_class.new }

  it 'fetches values with keys' do
    expect(lookup).to receive(:where).with('key IN (?)', [1])

    subject.foo = [1]
    subject.foo
  end

  it 'fetches values with different key name' do
    client_class.lookup :bar, lookup, key_column: :id, name_column: :place
    expect(lookup).to receive(:where).with('id IN (?)', [1])

    subject.bar = [1]
    subject.bar
  end

  it 'returns ids from lookup' do
    subject.foo = [1,2]
    expect(subject.foo_ids).to eq([1,2])
  end

  it 'returns an empty hash if ar_lookups empty' do
    expect(lookup).to receive(:none).exactly(2).times
    expect(subject.foo).to eq(lookup.none)
  end

  it 'returns a lookup hash' do
    subject.foo = [1,2]
    expect(subject.foo).to be_kind_of(Dummy)
  end

  it 'can be serialized to json' do
    subject.foo = [1, 2]
    json = subject.to_json(includes: { foo: { only: [:id, :value] } })
    expect(JSON.parse(json)).to eq("foo" => [{"id" => 1, "value" => 'Some Val'},{"id" => 2, "value" => 'Some Val'}])
  end

  it 'implicitly gets the model name from the column' do
    client_class.class_eval do
      lookup :foo_bars
    end

    expect(client_class.ar_lookups[:foo_bars]).to be(FooBar)
  end
end
