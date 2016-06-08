module Mjml
  class Parser

    # Create new parser
    #
    # @param input [String] The string to transform in html
    def initialize input
      file = File.open(in_tmp_file, 'w')
      file.write(input)
      file.close
    end

    # Render mjml template
    #
    # @return [String]
    def render
      result = run
      remove_tmp_files
      result
    rescue

      ""
    end

    # Exec mjml command
    #
    # @return [String] The result as string
    def run
      command = "#{mjml_bin} -r #{in_tmp_file} -o #{out_tmp_file}"
      # puts command
      `#{command}`
      file = File.open(out_tmp_file, 'r')
      str  = file.read
      file.close
      str
    end

    private

      # Remove tmp files
      #
      # @return nil
      def remove_tmp_files
        FileUtils.rm(in_tmp_file)
        FileUtils.rm(out_tmp_file)
        nil
      end

      # Return tmp dir
      #
      # @return [String]
      def tmp_dir
        "/tmp"
      end

      # Get parser tpm file to store result
      #
      # @return [String]
      def out_tmp_file

        @_out_tmp_file ||= "#{tmp_dir}/out_#{(0...8).map { (65 + rand(26)).chr }.join}.html"
      end

      # Get parser tpm file to get result
      #
      # @return [String]
      def in_tmp_file

        @_in_tmp_file ||= "#{tmp_dir}/in_#{(0...8).map { (65 + rand(26)).chr }.join}.mjml"
        # puts @_in_tmp_file
        return @_in_tmp_file
      end

      # Get mjml bin path
      #
      # @return [String]
      def mjml_bin
        global_bin_path = '/usr/bin/which mjml'.chomp
        local_bin_path  = File.join(Rails.root, 'node_modules', '.bin', 'mjml')
      
        global_bin_path unless File.exist?(local_bin_path)
        local_bin_path
      end
  end
end
