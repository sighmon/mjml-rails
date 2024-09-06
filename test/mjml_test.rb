# frozen_string_literal: true

require 'test_helper'

class NotifierMailer < ActionMailer::Base
  self.view_paths = File.expand_path('views', __dir__)

  layout 'default'

  def inform_contact(recipient)
    @recipient = recipient

    mail(to: @recipient, from: 'app@example.com') do |format|
      format.text
      format.html
    end
  end

  def invalid_template(recipient)
    @recipient = recipient

    mail(to: @recipient, from: 'app@example.com') do |format|
      format.html
      format.text
    end
  end
end

class NoLayoutMailer < ActionMailer::Base
  self.view_paths = File.expand_path('views', __dir__)

  layout nil

  def inform_contact(recipient)
    @recipient = recipient

    mail(to: @recipient, from: 'app@example.com', &:mjml)
  end

  def with_owa(recipient)
    @recipient = recipient

    mail(to: @recipient, from: 'app@example.com', &:mjml)
  end
end

class NotifierMailerTest < ActiveSupport::TestCase
  test 'MJML layout based multipart email is generated correctly' do
    email = NotifierMailer.inform_contact('user@example.com')

    assert_equal 'multipart/alternative', email.mime_type

    # To debug tests:
    # Mjml.logger.info email.mime_type
    # Mjml.logger.info email.to_s
    # Mjml.logger.info email.html_part.body

    assert_not email.html_part.body.match(%r{</?mj.+?>})
    assert email.html_part.body.include?('<body')
    assert email.html_part.body.match(/Hello, user@example.com!/)
    assert email.html_part.body.include?('<h2>We inform you about something</h2>')
    assert email.html_part.body.match(%r{<a href="https://www.example.com">this link</a>})
    assert email.html_part.body.include?('tracking-code-123')

    assert email.text_part.body.include?('We inform you about something')
    assert email.text_part.body.match(%r{Please visit https://www.example.com})
  end

  test 'Invalid template raises error with validation level strict' do
    with_settings(validation_level: 'strict') do
      email = NotifierMailer.invalid_template('user@example.com')
      assert_raise(ActionView::Template::Error) { email.html_part.body.to_s }
    end
  end

  test 'Invalid template gets compiled with validation level soft' do
    # suppress warning of MJML binary
    Mjml.logger.stubs(:warn)

    with_settings(validation_level: 'soft') do
      email = NotifierMailer.invalid_template('user@example.com')
      assert email.text_part.body.include?('This is valid')
      assert email.html_part.body.include?('This is valid')
      assert_not email.html_part.body.include?('This is invalid')
    end
  end
end

class NotifierMailerTest < ActiveSupport::TestCase
  test 'old mjml-rails configuration style MJML template is rendered correctly' do
    email = NoLayoutMailer.inform_contact('user@example.com')

    assert_equal 'text/html', email.mime_type

    assert_not email.body.match(%r{</?mj.+?>})
    assert email.body.include?('<body')
    assert email.body.match(/Welcome, user@example.com!/)
    assert email.body.include?('<h2>We inform you about something</h2>')
    assert email.body.match(%r{<a href="https://www.example.com">this link</a>})
    assert_not email.body.include?('tracking-code-123')
  end

  test 'old mjml-rails MJML template with owa is rendered correctly' do
    email = NoLayoutMailer.with_owa('user@example.com')

    assert_equal 'text/html', email.mime_type

    assert_not email.body.match(%r{</?mj.+?>})
    assert email.body.include?('<body')
    assert email.body.match(/Welcome, user@example.com!/)
    assert email.body.include?('<h2>We inform you about something</h2>')
    assert email.body.match(%r{<a href="https://www.example.com">this link</a>})
    assert_not email.body.include?('tracking-code-123')
  end
end

describe Mjml do
  describe '#valid_mjml_binary' do
    before do
      Mjml.mjml_binary = nil
      Mjml.valid_mjml_binary = nil
      Mjml.use_mrml = nil
    end

    after do
      Mjml.mjml_binary = nil
      Mjml.valid_mjml_binary = nil
      Mjml.use_mrml = nil
    end

    it 'can be set to a custom value with mjml_binary if version is correct' do
      Mjml.mjml_binary = 'some custom value'
      Mjml.stub :check_version, true do
        expect(Mjml.valid_mjml_binary).must_equal 'some custom value'
      end
    end

    it 'raises an error if mjml_binary is invalid' do
      Mjml.mjml_binary = 'some custom value'
      err = expect { Mjml.valid_mjml_binary }.must_raise(StandardError)
      assert(err.message.start_with?("MJML.mjml_binary is set to 'some custom value' " \
                                     'but MJML-Rails could not validate that it is a valid MJML binary'))
    end

    it 'honors old Mjml::BIN way of setting custom binary' do
      silence_warnings { Mjml::BIN = 'set by old way' }
      Mjml.logger.expects(:warn).with(regexp_matches(/Setting `Mjml::BIN` is deprecated/))
      err = expect { Mjml.valid_mjml_binary }.must_raise(StandardError)
      assert(err.message.start_with?("MJML.mjml_binary is set to 'set by old way' " \
                                     'but MJML-Rails could not validate that it is a valid MJML binary'))
    end

    it 'ignores empty Mjml::BIN' do
      Mjml::BIN = ''
      Mjml.mjml_binary = 'set by mjml_binary'

      err = expect { Mjml.valid_mjml_binary }.must_raise(StandardError)
      assert(err.message.start_with?("MJML.mjml_binary is set to 'set by mjml_binary' " \
                                     'but MJML-Rails could not validate that it is a valid MJML binary'))
    end

    it 'can use MRML and check for a valid binary' do
      Mjml.use_mrml = true
      Mjml.stubs(:check_for_custom_mjml_binary).returns(false)
      Mjml.stubs(:check_for_package_mjml_binary).returns(false)
      Mjml.stubs(:check_for_global_mjml_binary).returns(false)
      expect(Mjml.valid_mjml_binary).must_equal(true)

      Mjml.valid_mjml_binary = nil
      MRML.stubs(:present?).raises(NameError)
      Mjml.stubs(:puts) # silence printed error message from test output
      assert_nil(Mjml.valid_mjml_binary)
      expect(Mjml.mjml_binary_error_string).must_equal 'Couldn\'t find MRML - did you add \'mrml\' to your Gemfile?'
    end

    it 'with nothing on the path, sets valid_mjml_binary to nil' do
      old_path = ENV['PATH']
      ENV['PATH'] = './test/fixtures/valid-mjml-binary/empty-path/'

      Mjml.stubs(:puts) # silence printed error message from test output
      assert_nil(Mjml.valid_mjml_binary)
    ensure
      ENV['PATH'] = old_path
    end
  end
end
