# frozen_string_literal: true

module Mjml
  class MrmlParser
    attr_reader :template_path, :input

    # Create new parser
    #
    # @param template_path [String] The path to the .mjml file
    # @param input [String] The string to transform in html
    def initialize(template_path, input)
      @template_path = template_path
      @input         = input
      @with_cache    = Cache.new(template_path)
    end

    # Render mjml template
    #
    # @return [String]
    def render
      @with_cache.cache do
        MRML.to_html(input)
      rescue NameError
        Mjml.logger.fatal('MRML is not installed. Please add `gem "mrml"` to your Gemfile.')
        raise
      rescue StandardError
        raise if Mjml.raise_render_exception

        ''
      end
    end
  end
end
