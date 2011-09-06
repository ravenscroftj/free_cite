# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key => "_freecite_session", 
  :secret => "i've been waiting so long to know where i'm going in the sunshine of your love"
 # :secret      => 'a83df91f535b906c601a63027c797faa06814a17a139d05ca1504acee7f9d40a176454f73d3212b6ef1f4ea22a245364fc548e772da17dc6dcf6b6391295cb50'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
