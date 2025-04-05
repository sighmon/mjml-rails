# frozen_string_literal: true

require 'digest'
require_relative 'cache'

module Mjml
  class Parser
    class ParseError < StandardError; end

    attr_reader :template_path, :input

    # Create new parser
    #
    # @param template_path [String] The path to the .mjml file
    # @param input [String] The content of the .mjml file
    def initialize(template_path, input)
      raise Mjml.mjml_binary_error_string unless Mjml.valid_mjml_binary

      @template_path = template_path
      @input         = input
      @with_cache    = Cache.new(template_path)
    end

    # rubocop:disable Metrics/MethodLength
    # Render MJML template
    #
    # @return [String]
    def render
      @with_cache.cache do
        in_tmp_file = Tempfile.open(['in', '.mjml']) do |file|
          file.write(input)
          file # return tempfile from block so #unlink works later
        end
        run(in_tmp_file.path)
      rescue StandardError
        raise if Mjml.raise_render_exception

        ''
      ensure
        in_tmp_file&.unlink
      end
    end
    # rubocop:enable Metrics/MethodLength

    # Exec mjml command
    #
    # @return [String] The result as string
    def run(in_tmp_file)
      Tempfile.create(['out', '.html']) do |out_tmp_file|
        _, stderr, status = Mjml.run_mjml(build_command(in_tmp_file, out_tmp_file))

        unless status.success?
          # The process status ist quite helpful in case of dying processes without STDERR output.
          # Node exit codes are documented here: https://node.readthedocs.io/en/latest/api/process/#exit-codes
          raise ParseError, "#{stderr.chomp}\n(process status: #{status})"
        end

        Mjml.logger.warn(stderr.chomp) if stderr.present?
        out_tmp_file.read
      end
    end

    # Build command string from config variables
    #
    # @return [String] Command string
    def build_command(in_file, out_file)
      command = "-r #{in_file} -o #{out_file.path} " \
                "--config.beautify #{Mjml.beautify} " \
                "--config.minify #{Mjml.minify} " \
                "--config.validationLevel #{Mjml.validation_level}"
      command += " --config.fonts '#{Mjml.fonts.to_json}'" unless Mjml.fonts.nil?
      command
    end
  end
end
