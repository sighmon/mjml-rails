# frozen_string_literal: true
require 'mrml'

module Mjml
  class MrmlParser
    attr_reader :input

    # Create new parser
    #
    # @param input [String] The string to transform in html
    def initialize(input)
      @input = input
    end

    # Render mjml template
    #
    # @return [String]
    def render
      MRML.to_html(input)
    rescue StandardError
      raise if Mjml.raise_render_exception

      ''
    end
  end
end
