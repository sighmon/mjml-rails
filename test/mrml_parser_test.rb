# frozen_string_literal: true

require 'test_helper'

describe Mjml::MrmlParser do
  let(:parser) { Mjml::MrmlParser.new('test_template', input) }

  describe '#render' do
    describe 'when input is valid' do
      let(:input) { '<mjml><mj-body><mj-text>Hello World</mj-text></mj-body></mjml>' }

      it 'returns html' do
        expect(parser.render).must_include 'Hello World</div>'
      end
    end

    describe 'when exception is raised' do
      let(:input) { '<mjml><body><mj-text>Hello World</mj-text></body></mjml>' }

      it 'raises exception with render exception enabled' do
        with_settings(raise_render_exception: true) do
          expect { parser.render }.must_raise(MRML::Error)
        end
      end

      it 'returns empty string with exception raising disabled' do
        with_settings(raise_render_exception: false) do
          expect(parser.render).must_equal ''
        end
      end
    end
  end
end
