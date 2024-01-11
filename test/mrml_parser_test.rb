# frozen_string_literal: true

require 'test_helper'

describe Mjml::MrmlParser do
  let(:input) { mock('input') }
  let(:parser) { Mjml::MrmlParser.new(input) }

  describe '#render' do
    describe 'when exception is raised' do
      let(:custom_error_class) { Class.new(StandardError) }
      let(:error) { custom_error_class.new('custom error') }

      before do
        parser.stubs(:run).raises(error)
      end

      it 'raises exception with render exception enabled' do
        with_settings(raise_render_exception: true) do
          err = expect { parser.render }.must_raise(custom_error_class)
          expect(err.message).must_equal error.message
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
