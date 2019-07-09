require 'open3'

module Mjml
  class Parser
    class ParseError < StandardError; end

    attr_reader :input

    # Create new parser
    #
    # @param input [String] The string to transform in html
    def initialize input
      raise Mjml.mjml_binary_error_string unless mjml_bin
      @input = input
    end

    # Render mjml template
    #
    # @return [String]
    def render
      in_tmp_file = Tempfile.open(["in", ".mjml"]) do |file|
        file.write(input)
        file # return tempfile from block so #unlink works later
      end
      run(in_tmp_file.path, Mjml.beautify, Mjml.minify)
    rescue => e
      raise e if Mjml.raise_render_exception
      ""
    ensure
      in_tmp_file.unlink
    end

    # Exec mjml command
    #
    # @return [String] The result as string
    def run(in_tmp_file, beautify=true, minify=false)
      Tempfile.create(["out", ".html"]) do |out_tmp_file|
        command = "#{mjml_bin} -r #{in_tmp_file} -o #{out_tmp_file.path} --config.beautify #{beautify} --config.minify #{minify}"
        Open3.popen3(command) do |_, _, stderr, wait_thr|
          if !stderr.eof?
            raise ParseError.new(stderr.read.chomp)
          elsif !wait_thr.value.success?
            raise ParseError.new("mjml exited non-zero exit status: #{wait_thr.value.exitstatus}")
          end
        end
        result = out_tmp_file.read
        raise ParseError.new('mjml returned empty string') if result.empty?
        result
      end
    end

    private

      # Get mjml bin path
      #
      # @return [String]
      def mjml_bin
        Mjml::BIN
      end
  end
end
