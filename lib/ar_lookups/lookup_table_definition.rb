module ArLookups
  module LookupTableDefinition
    def lookup(column, options = {})
      send(:integer, column, options.merge(array: true, default: []))
    end
  end
end
