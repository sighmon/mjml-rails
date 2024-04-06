# frozen_string_literal: true

module Mjml
  class Parser
    class ParseError < StandardError; end

    attr_reader :input

    # Create new parser
    #
    # @param input [String] The string to transform in html
    def initialize(input)
      raise Mjml.mjml_binary_error_string unless Mjml.valid_mjml_binary

      @input = input
    end

    # Render mjml template
    #
    # @return [String]
    def render
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
