require "rails/generators/erb/mailer/mailer_generator"

module Mjml
  module Generators
    class MailerGenerator < Erb::Generators::MailerGenerator
      source_root File.expand_path("../templates", __FILE__)

      private

      def format
        :html
      end

      def formats
        [format]
      end

      def handler
        :mjml
      end

      def view_handler
        Mjml.configuration.template_language
      end

      def filename_with_extensions(name, file_format = format)
        # Due to MJML single-pass processing nature
        # layout files MUST have .mjml extension, but views/templates cannot
        is_layout_file = name.in?([:layout, "mailer"])
        [name, file_format, is_layout_file ? handler : view_handler].compact.join(".")
      end
    end
  end
end
