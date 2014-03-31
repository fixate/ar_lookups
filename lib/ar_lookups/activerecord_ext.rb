module ArLookups
  module ActiveRecordExt
    def ar_lookups
      @ar_lookups ||= superclass.respond_to?(:ar_lookups) ? superclass.ar_lookups.dup : {}
    end

    def lookup(column, *args)
      options = args.extract_options!
      lookup_model = args.first

      options.reverse_merge!(key_column: :key, name_column: :name)

      # Directly override accessors and super to the module below
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{column}; super; end
        def #{column}=(value); super; end
      RUBY

      ar_lookups[column] = lookup_model || implicit_lookup_class(column)

      # Mixin this Module so that we can use super in these functions
      mod = Module.new
      include mod
      mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{column}
          keys = read_attribute(:#{column})
          klass = self.class.ar_lookups[:#{column}]
          return klass.none if keys.blank?
          self.class.ar_lookups[:#{column}].where('#{options[:key_column]} IN (?)', keys)#.pluck(:#{options[:key_column]}, :#{options[:name_column]})]
        end

        def #{column}_ids
          read_attribute(:#{column})
        end

        def #{column}=(val)
          write_attribute(:#{column}, val)
        end
      RUBY
    end

    private

    def implicit_lookup_class(column)
      column.to_s.camelize.singularize.constantize
    end
  end
end
