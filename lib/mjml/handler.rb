# frozen_string_literal: true

require 'action_view'
require 'action_view/template'
require 'rails/version'

module Mjml
  class Handler
    def template_handler
      @template_handler ||= ActionView::Template.registered_template_handler(Mjml.template_language)
    end

    # Optional second source parameter to make it work with Rails >= 6:
    # Beginning with Rails 6 template handlers get the source of the template as the second
    # parameter.
    def call(template, source = nil)
      compiled_source = compile_source(source, template)

      parser_class = Mjml.use_mrml ? 'MrmlParser' : 'Parser'
      template_path = template.respond_to?(:virtual_path) ? template.virtual_path : template.identifier
      # Per MJML v4 syntax documentation[0] valid/render'able document MUST start with <mjml> root tag
      # If we get here and template source doesn't start with one it means
      # that we are rendering partial named according to legacy naming convention (partials ending with '.mjml')
      # Therefore we skip MJML processing and return raw compiled source. It will be processed
      # by MJML library when top-level layout/template is rendered
      #
      # [0] - https://github.com/mjmlio/mjml/blob/master/doc/components_1.md#mjml
      if /<mjml.*?>/i.match?(compiled_source)
        "Mjml::#{parser_class}.new('#{template_path}', begin;#{compiled_source};end).render.html_safe"
      else
        compiled_source
      end
    end

    private

    def compile_source(source, template)
      if Rails::VERSION::MAJOR >= 6
        template_handler.call(template, source)
      else
        template_handler.call(template)
      end
    end
  end
end
