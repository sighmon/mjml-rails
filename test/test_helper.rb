# frozen_string_literal: true

require 'rubygems'
require 'bundler'
Bundler.setup

require 'minitest/autorun'
require 'active_support'
require 'active_support/test_case'

require 'action_mailer'
require 'rails/railtie'
require 'rails/generators'
require 'rails/generators/test_case'
require 'mocha/minitest'
require 'byebug'

# require "minitest/reporters"
# Minitest::Reporters.use!

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'mjml'
Mjml::Railtie.run_initializers

ActiveSupport::TestCase.test_order = :sorted if ActiveSupport::TestCase.respond_to? :test_order=

# Avoid annoying warning from I18n.
I18n.enforce_available_locales = false

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true

def with_settings(settings)
  original_settings = settings.each_with_object({}) { |(key, _), agg| agg[key] = Mjml.public_send(key) }
  settings.each { |key, value| Mjml.public_send("#{key}=", value) }
  yield
ensure
  original_settings.each { |key, value| Mjml.public_send("#{key}=", value) }
end

# Suppress all ruby warnings of the mail gem, see:
# * https://github.com/mikel/mail/issues/1424
# * https://github.com/mikel/mail/issues/1384
# * https://github.com/mikel/mail/pull/1162
require 'warning'
Warning.ignore(//, %r{.*gems/mail.*/lib/mail/})
