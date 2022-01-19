# frozen_string_literal: true

require 'rubygems'
require 'posix/spawn'

require 'mjml/handler'
require 'mjml/parser'

require 'mjml/railtie' if defined?(Rails)

module Mjml
  mattr_accessor \
    :beautify,
    :minify,
    :mjml_binary,
    :mjml_binary_error_string,
    :mjml_binary_version_supported,
    :raise_render_exception,
    :template_language,
    :validation_level

  mattr_writer :valid_mjml_binary

  self.template_language = :erb
  self.raise_render_exception = true
  self.mjml_binary_version_supported = '4.'
  self.mjml_binary_error_string = "Couldn't find the MJML #{Mjml.mjml_binary_version_supported} binary.." \
                                  ' have you run $ npm install mjml?'
  self.beautify = true
  self.minify = false
  self.validation_level = 'strict'

  def self.check_version(bin)
    stdout, _, status = run_mjml('--version', mjml_bin: bin)
    status.success? && stdout.include?("mjml-core: #{Mjml.mjml_binary_version_supported}")
  rescue StandardError
    false
  end

  def self.run_mjml(args, mjml_bin: valid_mjml_binary)
    capture3("#{mjml_bin} #{args}")
  end

  def self.valid_mjml_binary
    self.valid_mjml_binary = @@valid_mjml_binary ||
                             check_for_custom_mjml_binary ||
                             check_for_yarn_mjml_binary ||
                             check_for_npm_mjml_binary ||
                             check_for_global_mjml_binary

    return @@valid_mjml_binary if @@valid_mjml_binary

    puts Mjml.mjml_binary_error_string
  end

  def self.check_for_custom_mjml_binary
    if const_defined?(:BIN) && Mjml::BIN.present?
      logger.warn('Setting `Mjml::BIN` is deprecated and will be removed in a future version! ' \
                  'Please use `Mjml.mjml_binary=` instead.')
      self.mjml_binary = Mjml::BIN
      remove_const :BIN
    end

    return if mjml_binary.blank?

    return mjml_binary if check_version(mjml_binary)

    raise "MJML.mjml_binary is set to '#{mjml_binary}' but MJML-Rails could not validate that " \
          'it is a valid MJML binary. Please check your configuration.'
  end

  def self.check_for_yarn_mjml_binary
    yarn_bin = `which yarn`.chomp
    return if yarn_bin.blank?

    mjml_bin = "#{yarn_bin} run mjml"
    return mjml_bin if check_version(mjml_bin)
  end

  def self.check_for_npm_mjml_binary
    npm_bin = `which npm`.chomp
    return unless npm_bin.present? && (installer_path = bin_path_from(npm_bin)).present?

    mjml_bin = File.join(installer_path, 'mjml')
    return mjml_bin if check_version(mjml_bin)
  end

  def self.check_for_global_mjml_binary
    mjml_bin = `which mjml`.chomp
    return mjml_bin if mjml_bin.present? && check_version(mjml_bin)
  end

  def self.bin_path_from(package_manager)
    stdout, _, status = capture3("#{package_manager} bin")

    return unless status.success?

    stdout.chomp
  rescue Errno::ENOENT # package manager is not installed
    nil
  end

  def self.discover_mjml_bin
    logger.warn('`Mjml.discover_mjml_bin` is deprecated and has no effect anymore! ' \
                'Please use `Mjml.mjml_binary=` to set a custom MJML binary.')
  end

  def self.setup
    yield self if block_given?
  end

  def self.capture3(cmd)
    pid, stdin, stdout, stderr = POSIX::Spawn.popen4(cmd)
    stdin.close
    out = stdout.read
    err = stderr.read
    _, status = Process.waitpid2(pid)
    [out, err, status]
  ensure
    [stdin, stdout, stderr].each { |io| io.close unless io.closed? }
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
