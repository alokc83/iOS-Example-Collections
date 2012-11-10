#
#  config.ru
#  Pass Server reference implementation
#
#  Copyright (c) 2012 Apple, Inc. All rights reserved.
#
require './pass_server'
puts "Please enter your certificate password: "
password_input = gets.chomp
PassServer.set :certificate_password, password_input

run PassServer