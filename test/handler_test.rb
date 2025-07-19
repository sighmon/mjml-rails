# frozen_string_literal: true

require 'test_helper'

class HandlerTest < ActiveSupport::TestCase
  def setup
    @handler = Mjml::Handler.new
  end

  test 'uses virtual_path when available' do
    template = mock
    template.stubs(:virtual_path).returns('/path/to/template')
    template.stubs(:respond_to?).with(:virtual_path).returns(true)

    compiled_source = '<mjml><mj-body><mj-text>Hello</mj-text></mj-body></mjml>'
    @handler.stubs(:compile_source).returns(compiled_source)

    result = @handler.call(template)

    assert_includes result, '/path/to/template'
  end

  test 'falls back to identifier when virtual_path is not available' do
    # Simulate ViewComponent::Template::DataWithSource behavior
    template = mock
    template.stubs(:identifier).returns('/path/to/component/template')
    template.stubs(:respond_to?).with(:virtual_path).returns(false)

    compiled_source = '<mjml><mj-body><mj-text>Hello</mj-text></mj-body></mjml>'
    @handler.stubs(:compile_source).returns(compiled_source)

    result = @handler.call(template)

    assert_includes result, '/path/to/component/template'
  end

  test 'handles partials without mjml root tag' do
    template = mock
    template.stubs(:virtual_path).returns('/path/to/partial')
    template.stubs(:respond_to?).with(:virtual_path).returns(true)

    # Partial without <mjml> root tag
    compiled_source = '<mj-text>This is a partial</mj-text>'
    @handler.stubs(:compile_source).returns(compiled_source)

    result = @handler.call(template)

    # Should return the compiled source as-is for partials
    assert_equal compiled_source, result
  end

  test 'processes full MJML documents' do
    template = mock
    template.stubs(:virtual_path).returns('/path/to/template')
    template.stubs(:respond_to?).with(:virtual_path).returns(true)

    compiled_source = '<mjml><mj-body><mj-text>Full document</mj-text></mj-body></mjml>'
    @handler.stubs(:compile_source).returns(compiled_source)

    result = @handler.call(template)

    # Should return parser invocation for full MJML documents
    assert_includes result, "Mjml::Parser.new('/path/to/template'"
    assert_includes result, '.render.html_safe'
  end

  test 'uses MrmlParser when use_mrml is true' do
    Mjml.stubs(:use_mrml).returns(true)

    template = mock
    template.stubs(:virtual_path).returns('/path/to/template')
    template.stubs(:respond_to?).with(:virtual_path).returns(true)

    compiled_source = '<mjml><mj-body><mj-text>Full document</mj-text></mj-body></mjml>'
    @handler.stubs(:compile_source).returns(compiled_source)

    result = @handler.call(template)

    assert_includes result, "Mjml::MrmlParser.new('/path/to/template'"
  ensure
    Mjml.unstub(:use_mrml)
  end
end
