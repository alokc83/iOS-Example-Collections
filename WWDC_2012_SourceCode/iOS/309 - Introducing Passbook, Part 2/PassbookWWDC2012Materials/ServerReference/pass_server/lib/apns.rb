# File:       apns.rb
#
# Abstract:   Pass Server reference implementation
#
# Version:    <1.0>
#
# Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc. ("Apple")
#             in consideration of your agreement to the following terms, and your use,
#             installation, modification or redistribution of this Apple software
#             constitutes acceptance of these terms.  If you do not agree with these
#             terms, please do not use, install, modify or redistribute this Apple
#             software.
#
#             In consideration of your agreement to abide by the following terms, and
#             subject to these terms, Apple grants you a personal, non - exclusive
#             license, under Apple's copyrights in this original Apple software ( the
#             "Apple Software" ), to use, reproduce, modify and redistribute the Apple
#             Software, with or without modifications, in source and / or binary forms;
#             provided that if you redistribute the Apple Software in its entirety and
#             without modifications, you must retain this notice and the following text
#             and disclaimers in all such redistributions of the Apple Software. Neither
#             the name, trademarks, service marks or logos of Apple Inc. may be used to
#             endorse or promote products derived from the Apple Software without specific
#             prior written permission from Apple.  Except as expressly stated in this
#             notice, no other rights or licenses, express or implied, are granted by
#             Apple herein, including but not limited to any patent rights that may be
#             infringed by your derivative works or by other works in which the Apple
#             Software may be incorporated.
#
#             The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
#             WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
#             WARRANTIES OF NON - INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
#             PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION
#             ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
#
#             IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
#             CONSEQUENTIAL DAMAGES ( INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#             SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#             INTERRUPTION ) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION
#             AND / OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER
#             UNDER THEORY OF CONTRACT, TORT ( INCLUDING NEGLIGENCE ), STRICT LIABILITY OR
#             OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Copyright ( C ) 2012 Apple Inc. All Rights Reserved.
#

require 'singleton'
require 'socket'
require 'openssl'

class APNS
  include Singleton
  attr_accessor :config, :certificate, :socket, :ssl_socket, :certificate_password

  def get_certificate_path
    certDirectory = File.dirname(File.expand_path(__FILE__)) + "/../Data/Certificate"
    certs = Dir.glob("#{certDirectory}/*.p12")
    if  certs.count ==0
	puts "Couldn't find a certificate at #{certDirectory}"
        puts "Exiting"
        Process.exit
    else
        certificate_path = certs[0]
    end
  end
  
  def initialize
    self.certificate_password = get_certificate_password
    self.certificate = load_certificate(get_certificate_path, self.certificate_password)
  end
  
  def get_certificate_password
    puts "Please enter your certificate password: "
    password_input = gets.chomp

    return password_input
  end
  
  def load_certificate(path, password=nil)
    context = OpenSSL::SSL::SSLContext.new
    context.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    # Import the certificate
    p12_certificate = OpenSSL::PKCS12::new(File.read(path), self.certificate_password)
    
    context.cert = p12_certificate.certificate
    context.key = p12_certificate.key
    
    # Return ssl certificate context
    return context
  end
  
  def open_connection(environment='sandbox')
    if self.certificate.class != OpenSSL::SSL::SSLContext
      puts "hello"
      load_certificate
    end
    
    if environment == "production"
      self.socket = TCPSocket.new("gateway.push.apple.com", 2195)
    else
      self.socket = TCPSocket.new("gateway.sandbox.push.apple.com", 2195)
    end
    self.ssl_socket = OpenSSL::SSL::SSLSocket.new(APNS.instance.socket, APNS.instance.certificate)

    # Open the SSL connection
    self.ssl_socket.connect
    
    
  end
  
  def close_connection
    APNS.instance.ssl_socket.close
    APNS.instance.socket.close
  end
  
  def deliver(token, payload)
    notification_packet = self.generate_notification_packet(token, payload)
    APNS.instance.ssl_socket.write(notification_packet)
  end
  
  def generate_notification_packet(token, payload)
    device_token_binary = [token.delete(' ')].pack('H*')
    
    packet =  [
                0,
                device_token_binary.size / 256,
                device_token_binary.size % 256,
                device_token_binary,
                payload.size / 256,
                payload.size % 256,
                payload
              ]
    packet.pack("ccca*cca*")
  end
  
  
end


