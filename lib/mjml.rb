require "rails/version"
require "action_view"
require "action_view/template"
require "mjml/mjmltemplate"
require "mjml/configuration"
require "mjml/railtie"
require "rubygems"
require "open3"

module Mjml
  def self.check_version(bin)
    IO.popen([bin, '--version']) { |io| io.read.include?("mjml-core: #{Mjml.configuration.mjml_binary_version_supported}") }
  rescue
    false
  end

  def self.discover_mjml_bin
    # Check for a global install of MJML binary
    mjml_bin = 'mjml'
    return mjml_bin if check_version(mjml_bin)

    # Check for a local install of MJML binary
    installer_path = bin_path_from('npm') || bin_path_from('yarn')
    unless installer_path
      puts Mjml.configuration.mjml_binary_error_string
      return nil
    end

    mjml_bin = File.join(installer_path, 'mjml')
    return mjml_bin if check_version(mjml_bin)

    puts Mjml.configuration.mjml_binary_error_string
    nil
  end

  def self.bin_path_from(package_manager)
    _, stdout, _, _ = Open3.popen3("#{package_manager} bin")
   stdout.read.chomp
  rescue Errno::ENOENT # package manager is not installed
    nil
  end

  BIN = discover_mjml_bin

  class Handler
    def template_handler
      @_template_handler ||= ActionView::Template.registered_template_handler(Mjml.configuration.template_language)
    end

    # Optional second source parameter to make it work with Rails >= 6:
    # Beginning with Rails 6 template handlers get the source of the template as the second
    # parameter.
    def call(template, source = nil)
      compiled_source =
        if Rails::VERSION::MAJOR >= 6
          template_handler.call(template, source)
        else
          template_handler.call(template)
        end

      # Per MJML v4 syntax documentation[0] valid/render'able document MUST start with <mjml> root tag
      # If we get here and template source doesn't start with one it means
      # that we are rendering partial named according to legacy naming convention (partials ending with '.mjml')
      # Therefore we skip MJML processing and return raw compiled source. It will be processed
      # by MJML library when top-level layout/template is rendered
      #
      # [0] - https://github.com/mjmlio/mjml/blob/master/doc/guide.md#mjml
      if compiled_source =~ /<mjml(.+)?>/i
        "Mjml::Mjmltemplate.to_html(begin;#{compiled_source};end).html_safe"
      else
        compiled_source
      end
    end
  end

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = self.name
      end
    end
  end
end
