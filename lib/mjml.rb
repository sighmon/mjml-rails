# frozen_string_literal: true

require 'rubygems'
require 'open3'

require 'mjml/handler'
require 'mjml/parser'
require 'mjml/mrml_parser'
require 'mjml/railtie' if defined?(Rails)

module Mjml
  mattr_accessor \
    :beautify,
    :minify,
    :fonts,
    :mjml_binary,
    :mjml_binary_error_string,
    :mjml_binary_version_supported,
    :raise_render_exception,
    :template_language,
    :validation_level,
    :use_mrml

  mattr_writer :valid_mjml_binary

  self.template_language = :erb
  self.raise_render_exception = true
  self.mjml_binary_version_supported = '4.'
  self.mjml_binary_error_string = "Couldn't find the MJML #{Mjml.mjml_binary_version_supported} binary.." \
                                  ' have you run $ npm install mjml?'
  self.beautify = true
  self.minify = false
  self.validation_level = 'strict'
  self.use_mrml = false
  self.fonts = nil

  def self.check_version(bin)
    stdout, _, status = run_mjml('--version', mjml_bin: bin)
    status.success? && stdout.include?("mjml-core: #{Mjml.mjml_binary_version_supported}")
  rescue StandardError
    false
  end

  def self.run_mjml(args, mjml_bin: valid_mjml_binary)
    Open3.capture3("#{mjml_bin} #{args}")
  end

  def self.valid_mjml_binary
    self.valid_mjml_binary = @@valid_mjml_binary ||
                             check_for_custom_mjml_binary ||
                             check_for_bun_mjml_binary ||
                             check_for_yarn_mjml_binary ||
                             check_for_npm_mjml_binary ||
                             check_for_global_mjml_binary ||
                             check_for_mrml_binary

    return @@valid_mjml_binary if @@valid_mjml_binary

    puts Mjml.mjml_binary_error_string
  end

  def self.check_for_custom_mjml_binary
    if const_defined?('BIN') && Mjml::BIN.present?
      logger.warn('Setting `Mjml::BIN` is deprecated and will be removed in a future version! ' \
                  'Please use `Mjml.mjml_binary=` instead.')
      self.mjml_binary = Mjml::BIN
      remove_const 'BIN'
    end

    return if mjml_binary.blank?

    return mjml_binary if check_version(mjml_binary)

    raise "MJML.mjml_binary is set to '#{mjml_binary}' but MJML-Rails could not validate that " \
          'it is a valid MJML binary. Please check your configuration.'
  end

  def self.check_for_bun_mjml_binary
    bun_bin = `which bun`.chomp
    return if bun_bin.blank?

    stdout, _, status = Open3.capture3("#{bun_bin} pm bin")
    return unless status.success?

    mjml_bin = File.join(stdout.chomp, 'mjml')
    return mjml_bin if check_version(mjml_bin)
  rescue Errno::ENOENT # package manager is not installed
    nil
  end

  def self.check_for_yarn_mjml_binary
    yarn_bin = `which yarn`.chomp
    return if yarn_bin.blank?

    stdout, _, status = Open3.capture3("#{yarn_bin} bin mjml")
    return unless status.success?

    mjml_bin = stdout.chomp
    return mjml_bin if check_version(mjml_bin)
  rescue Errno::ENOENT # package manager is not installed
    nil
  end

  def self.check_for_npm_mjml_binary
    npm_bin = `which npm`.chomp
    return if npm_bin.blank?

    stdout, _, status = Open3.capture3("#{npm_bin} root")
    return unless status.success?

    mjml_bin = File.join(stdout.chomp, '.bin', 'mjml')
    return mjml_bin if check_version(mjml_bin)
  rescue Errno::ENOENT # package manager is not installed
    nil
  end

  def self.check_for_global_mjml_binary
    mjml_bin = `which mjml`.chomp
    return mjml_bin if mjml_bin.present? && check_version(mjml_bin)
  end

  def self.check_for_mrml_binary
    MRML.present?
  rescue NameError
    Mjml.mjml_binary_error_string = 'Couldn\'t find MRML - did you add \'mrml\' to your Gemfile?'
    false
  end

  def self.discover_mjml_bin
    logger.warn('`Mjml.discover_mjml_bin` is deprecated and has no effect anymore! ' \
                'Please use `Mjml.mjml_binary=` to set a custom MJML binary.')
  end

  def self.setup
    yield self if block_given?
  end

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end
  end
end
