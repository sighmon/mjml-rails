# frozen_string_literal: true

require 'rails/generators'

module Mjml
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
      desc 'Creates MJML initializer for your application'

      def copy_initializer
        template 'mjml.rb', 'config/initializers/mjml.rb'
      end
    end
  end
end
