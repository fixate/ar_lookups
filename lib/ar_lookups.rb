require 'active_record'

require 'ar_lookups/version'
require 'ar_lookups/lookup_table_definition'
require 'ar_lookups/base_ext'
require 'ar_lookups/railtie' if defined?(Rails)

module ArLookups
  def self.eager_load!
  end
end
