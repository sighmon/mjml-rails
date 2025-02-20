## 4.14.1

* Tom Naessens prioritised mrml binary check to avoid mjml binary check warnings.

## 4.14.0

* Emi added Windows support.

## 4.13.0

* Noel Blaschke added support for Bun without Node.js

## 4.12.1

* Paul Hinze fixed a stray stderr output on machines with GNU which.

## 4.12.0

* Ray Brown added support for the Bun package manager.

## 4.11.0

* Claire Zuliani added config settings for MJML fonts.
  
## 4.10.1

* Fixed the binary check when using MRML to avoid warnings.

## 4.10.0

* Pokonski added support for MRML which is a fast Rust implementation of MJML.

## 4.9.0

* Yuta Hayashi added support for Yarn 2.

## 4.8.0

* Alan Halatian updated the MJML binary discovery when installed with Yarn.

## 4.7.2

* Florian Dütsch added the Node process exit code when the parser raises a ParseError.

## 4.7.1

* Florian Dütsch fixed a bug where Mjml::Parser#render suppresses errors in case of Tempfile exceptions.

## 4.7.0

* Florian Dütsch added RuboCop integration.

## 4.6.1

* doits simplified the MJML Handler class and regex, so rendering should be faster.

## 4.6.0

* doits added custom MJML binary location configuration via mjml_binary setting.

## 4.5.0

* **Note**: default validation level is now *strict*.
* doits fixed MJML-Rails validation level to match MJML validation.
* haffla fixed the post-install message.

## 4.4.2

* Implement denny's fix to detect MJML template errors.

## 4.4.1

* doits refactored discovery of the MJML binary.

## 4.4.0

* zeh235 added support for setting the MJML validationLevel.

## 4.3.2

* adrianob fixed discovering the npm/yarn bin path using Open3 instead of back ticks.

## 4.3.1

* Jan Sandbrink fixed discovering MJML binary, when only yarn, but not npm is installed.

## 4.3.0

* Paul Mucur added better path escaping on the IO.popen command. Markus Doits added Rails 6 support by adding the optional second source parameter to template handler calls.

## 4.2.5

* Stephan Biastoch added rendering errors to true by default - see pull request #37.

## 4.2.4

* Mandy Huang added config settings for MJML beautify and minify.

## 4.2.3

* Patrick Bougie and Daniel suggested a fix to enable alternative binary support - see #39. Also updated for MJML 4.2.0

## 4.2.2

* Patrick Bougie fixed a bug where an expanded MJML root tag <mjml owa="desktop"> resulted in the message not rendering to HTML.

## 4.2.1

* Implemented Aleksandrs Ļedovskis' fix for Haml/Slim layouts.

## 4.2.0

* Aleksandrs Ļedovskis refactored MJML layout/template support to better match Rails standards.

## 4.1.0

* Ryan Ahearn updated for 4.1.0 and improved Tempfile usage.

## 4.0.3

* Anh Tran added the use of Open3.popen3 to support error raising for Mjml::Parse#run method.

## 4.0.2

* Max Mulatz, 🧟‍ squisher. Fixed a zombie process from the version checker (also cutest pull-request 🏆).

## 4.0.1

* Option to raise render errors added to the config by Anh Tran.

## 4.0.0

* Updated for MJML v4.0.0 thanks to JP Boily.

## 2.4.3

* Checks if Yarn is installed for webpacker users.

## 2.4.2

* Only raise error when really using mjml if binary is not found.

## 2.4.1

* Using IO.popen from tylerhunt's branch to check if the MJML binary is installed.

## 2.3.0

* Updated to support HAML and other template languages.

## 2.2.0

* Updated to work with MJML v2.x
* Performing executable checks and version checks at initialize time.

## 2.1.4.1

* Removing require: 'mjml' from the Gemfile install line.

## 2.1.4

* Updated to MJML v2.1.4

## 2.1.1

* Supports new tags in MJML v2.1.1
* Version number now matches MJML.io version

## 1.0.0

* First release.
* Supports MJML 1.x
* Allows use of ERb in templates
* Allows use of partials in templates
