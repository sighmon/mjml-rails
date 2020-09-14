module Mjml
  class Configuration
    attr_accessor :template_language,
                  :raise_render_exception,
                  :mjml_binary_version_supported,
                  :mjml_binary_error_string,
                  :beautify,
                  :minify,
                  :validation_level

    def initialize
      @template_language = :erb
      @raise_render_exception = true
      @mjml_binary_version_supported = "4."
      @mjml_binary_error_string = "Couldn't find the MJML #{mjml_binary_version_supported} binary.. have you run $ npm install mjml?"
      @beautify = true
      @minify = false
      @validation_level = "soft"
      @mjml_binary_path = nil
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configuration=(configuration)
      @configuration = configuration
    end

    def configure(&block)
      yield configuration
    end

    alias_method :setup, :configure
  end
end
