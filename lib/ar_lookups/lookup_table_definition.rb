module ArLookups
  module LookupTableDefinition
    def lookup(column, options = {})
      send(options.delete(:type) || :integer, column, options.merge(array: true, default: []))
    end
  end
end
