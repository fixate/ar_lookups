require "rails"

module ArLookups
  class Railtie < Rails::Railtie # :nodoc:
    config.eager_load_namespaces << ArLookups

    initializer "ar_lookups.initialize" do |app|
      ActiveSupport.on_load(:active_record) do
        # Extend migration table definition
        ActiveRecord::ConnectionAdapters::TableDefinition.send :include,
          ArLookups::LookupTableDefinition

        # Extend AR base
        ActiveRecord::Base.send :extend,
          ArLookups::BaseExt
      end
    end
  end
end
