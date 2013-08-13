# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.

require 'securerandom'

def secure_token
  token_file = Rails.root.join('.secret')
  if File.exist?(token_file)
    # Use the existing token.
    File.read(token_file).chomp
  else
    # Generate a new token and store it in token_file.
    token = SecureRandom.hex(64)
    File.write(token_file, token)
    token
  end
end

Dicet::Application.config.secret_key_base = secure_token

#Dicet::Application.config.secret_key_base = '1bcfda0529413f4407ec7a14b1735f49230a0eb9084bdc6f0afdd12618fad08ed071e664d294940930d13bb05779f5acb127dd3a7c95ef41749ab0430b7f09af'
