#
#  sign_pass.gemspec
#  signpass
#
#  Copyright (c) 2012 Apple, Inc. All rights reserved.
#

Gem::Specification.new do |s|
  s.name        = 'sign_pass'
  s.version     = '0.1.7'
  s.date        = '2012-05-31'
  s.summary     = "Packages and signs passes."
  s.description = "A ruby implementation of the pass signing and packaging utility."
  s.authors     = ["Apple"]
  s.files       = ["lib/sign_pass.rb"]
  s.homepage    = "http://www.apple.com"
  s.email       = "info@apple.com"
  s.executables << "rsign_pass"
  s.add_dependency('rubyzip', '>= 0.9.5') 
end
