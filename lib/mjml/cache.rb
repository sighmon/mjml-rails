# frozen_string_literal: true

module Mjml
  class Cache
    attr_reader :template_path

    def initialize(template_path)
      @template_path = template_path
    end

    # @yield [] -> String
    # @return [String]
    def cache(&block)
      return yield if !Mjml.cache_mjml && block

      cached_path = cached_file_path
      if File.exist?(cached_path)
        File.read(cached_path)
      else
        html_content = yield if block
        File.write(cached_path, html_content)
        html_content
      end
    end

    private

    def cached_file_path
      File.join(cache_directory, "#{fingerprint}.html")
    end

    def fingerprint
      full_path = File.join(Dir.pwd, 'app', 'views', "#{template_path}.mjml")
      raise "Template file not found: #{full_path}" unless File.exist?(full_path)

      Digest::SHA256.hexdigest(File.read(full_path))
    end

    def cache_directory
      dir = File.join(Dir.pwd, 'tmp', 'mjml_cache')
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      dir
    end
  end
end
