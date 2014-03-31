require 'nulldb/rails'
ActiveRecord::Base.establish_connection adapter: :nulldb
