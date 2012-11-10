#
# File:       sign_pass.rb
#
# Abstract:   Pass Server reference implementation
#
# Version:    1.0
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

require 'rubygems'
require 'fileutils'
require 'tmpdir'
require 'digest/sha1'
require 'json'
require 'openssl'
require 'zip/zip'
require 'zip/zipfilesystem'


class SignPass
  attr_accessor :pass_url, :certificate_url, :certificate_password, :output_url, :compress_into_zip_file, :temporary_directory, :temporary_path, :manifest_url, :signature_url
  
  
  def initialize(pass_url, certificate_url, certificate_password, output_url, compress_into_zip_file=true)
    self.pass_url               = pass_url
    self.certificate_url        = certificate_url
    self.certificate_password   = certificate_password
    self.output_url             = output_url
    self.compress_into_zip_file = compress_into_zip_file
  end
  
  
  def sign_pass!(force_clean_raw_pass=false)
    # Validate that requested contents are not a signed and expanded pass archive.
    self.validate_directory_as_unsigned_raw_pass(force_clean_raw_pass)
    
    # Get a temporary place to stash the pass contents
    self.create_temporary_directory
    
    # Make a copy of the pass contents to the temporary folder
    self.copy_pass_to_temporary_location
    
    # Clean out the unneeded .DS_Store files
    self.clean_ds_store_files
    
    # Build the json manifest
    self.generate_json_manifest
    
    # Sign the manifest
    self.sign_manifest
    
    # Package pass
    self.compress_pass_file
    
    # Clean up the temp directory
    #self.delete_temp_dir
  end
  
  
  # private
  
  # Ensures that the raw pass directory does not contain signatures
  def validate_directory_as_unsigned_raw_pass(force_clean=false)
    if force_clean
      force_clean_raw_pass
    end
    
    has_manifiest = File.exists?(File.join(self.pass_url, "/manifest.json"))
    puts "Raw pass has manifest? #{has_manifiest}"
    
    has_signiture = File.exists?(File.join(self.pass_url, "/signature"))
    puts "Raw pass has signature? #{has_signiture}"
        
    if has_signiture || has_manifiest
      raise RuntimeError, "#{self.pass_url} contains pass signing artificats that need to be removed before signing."
      
    end
  end
  
  def force_clean_raw_pass
    puts "Force cleaning the raw pass directory."
    if File.exists?(File.join(self.pass_url, "/manifest.json"))
      File.delete(File.join(self.pass_url, "/manifest.json"))
    end
    
    if File.exists?(File.join(self.pass_url, "/signature"))
      File.delete(File.join(self.pass_url, "/signature"))
    end
    
  end
  
  
  # Creates a temporary place to work with the pass files without polluting the original
  def create_temporary_directory
    self.temporary_directory = Dir.mktmpdir
    puts "Creating temp dir at #{self.temporary_directory}"
    self.temporary_path = self.temporary_directory + "/" + self.pass_url.split("/").last
    
    # Check if the directory exists
    if File.directory?(self.temporary_path)
      # Need to clean up the directory
      FileUtils.rm_rf(self.temporary_path)
    end
    
  end
  
  # Copies the pass contents to the temporary location
  def copy_pass_to_temporary_location
    puts "Copying pass to temp directory."
    FileUtils.cp_r(self.pass_url, self.temporary_directory)
  end
  
  
  # Removes .DS_Store files if they exist
  def clean_ds_store_files
    puts "Cleaning .DS_Store files"
    Dir.glob(self.temporary_path + "**/.DS_Store").each do |file|
      File.delete(file)
    end
    
  end
  
  
  # Creates a json manifest where each files contents has a SHA1 hash
  def generate_json_manifest
    puts "Generating JSON manifest"
    manifest = {}
    # Gather all the files and generate a sha1 hash
    Dir.glob(self.temporary_path + "/**").each do |file|
      manifest[File.basename(file)] = Digest::SHA1.hexdigest(File.read(file))
    end
    
    # Write the hash dictionary out to a manifest file
    self.manifest_url = self.temporary_path + "/manifest.json"
    File.open(self.manifest_url, "w") do |f|
      f.write(JSON.pretty_generate(manifest))
    end
    
  end
  
  def sign_manifest
    puts "Signing the manifest"
    # Import the certificate
    p12_certificate = OpenSSL::PKCS12::new(File.read(self.certificate_url), self.certificate_password)
    
    # Sign the data
    flag = OpenSSL::PKCS7::BINARY|OpenSSL::PKCS7::DETACHED
    signed = OpenSSL::PKCS7::sign(p12_certificate.certificate, p12_certificate.key, File.read(self.manifest_url), [], flag)
    
    # Create an output path for the signed data
    self.signature_url = self.temporary_path + "/signature"
    
    # Write out the data
    File.open(self.signature_url, "w") do |f|
      f.write signed.to_der
    end
  end
  
  def compress_pass_file
    puts "Compressing the pass"
    zipped_file = File.open(self.output_url, "w")
    
    Zip::ZipOutputStream.open(zipped_file.path) do |z|
      Dir.glob(self.temporary_path + "/**").each do |file|
        z.put_next_entry(File.basename(file))
        z.print IO.read(file)
      end
    end
    zipped_file
  end
  
  def delete_temp_dir
    FileUtils.rm_rf(self.temporary_path)
  end
end














