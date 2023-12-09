# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'mjml/version'

Gem::Specification.new do |s| # rubocop:disable Gemspec/RequireMFA
  s.name                  = 'mjml-rails'
  s.version               = Mjml::VERSION.dup
  s.platform              = Gem::Platform::RUBY
  s.summary               = 'MJML + ERb templates'
  s.email                 = 'sighmon@sighmon.com'
  s.homepage              = 'https://github.com/sighmon/mjml-rails'
  s.description           = 'Render MJML + ERb template views in Rails'
  s.authors               = ['Simon Loffler', 'Steven Pickles']
  s.license               = 'MIT'
  s.required_ruby_version = '>= 2.5'

  s.cert_chain  = ['certs/sighmon.pem']
  s.signing_key = File.expand_path('~/.ssh/gem-private_key.pem') if $PROGRAM_NAME.end_with?('gem')

  s.files         = Dir['MIT-LICENSE', 'README.md', 'lib/**/*']
  s.test_files    = Dir['test/**/*.rb']
  s.require_paths = ['lib']
  s.post_install_message = "Don't forget to install MJML e.g. \n$ npm install mjml"

  s.add_dependency 'mrml'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'mocha', '2.1.0'
  s.add_development_dependency 'rails'
  s.add_development_dependency 'rubocop', '~> 1.23.0'
  s.add_development_dependency 'rubocop-performance', '~> 1.12.0'
  s.add_development_dependency 'rubocop-rails', '~> 2.12.4'
  s.add_development_dependency 'warning', '1.2.1'
end
