# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_unravel_session',
  :secret      => '5be80bebb5ffb8e055bead1250dc7249b03a1486dbb35aa4ac86b1c59a432174256cab26d0102c3d66b9d25622a2b88d994a8e20d8fe0ae922068454ab06cd63'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
