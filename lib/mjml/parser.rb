# frozen_string_literal: true

module Mjml
  class Parser
    class ParseError < StandardError; end

    attr_reader :input
    attr_reader :path

    # Create new parser
    #
    # @param input [String] The string to transform in html
    def initialize(input, path)
      raise Mjml.mjml_binary_error_string unless Mjml.valid_mjml_binary

      @input = input
      @path = path
    end

    # Render mjml template
    #
    # @return [String]
    def render
      run(input, Mjml.beautify, Mjml.minify, Mjml.validation_level)
    rescue StandardError
      raise if Mjml.raise_render_exception

      ''
    ensure
      # in_tmp_file&.unlink
    end

    # Exec mjml command
    #
    # @return [String] The result as string
    # rubocop:disable Style/OptionalBooleanParameter: Fixing this offense would imply a change in the public API.
    def run(input, beautify = true, minify = false, validation_level = 'strict')
      command = "-i " \
                "--config.beautify #{beautify} --config.minify #{minify} --config.validationLevel #{validation_level} " \
                "--config.filePath #{path}"
      stdout, stderr, status = Mjml.run_mjml(command, stdin_data: input)

      unless status.success?
        # The process status ist quite helpful in case of dying processes without STDERR output.
        # Node exit codes are documented here: https://node.readthedocs.io/en/latest/api/process/#exit-codes
        raise ParseError, "#{stderr.chomp}\n(process status: #{status})"
      end

      Mjml.logger.warn(stderr.chomp) if stderr.present?
      stdout
    end
    # rubocop:enable Style/OptionalBooleanParameter
  end
end
