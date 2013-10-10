# Load the rails application
require File.expand_path('../application', __FILE__)

# credentials for remote bitcoind app
BitcoinApp::Application.configure do
  config.user = "bitcoind"
  config.password = "password"  
  config.host = "88.88.88.88" # real ip address should be here
  config.port = 33333
end


=begin
BitcoinApp::Application.configure do
  config.user = "bitcoind"
  config.password = "password1234567890"  
  config.host = "127.0.0.1"
  config.port = 8332
end
=end

# Initialize the rails application
BitcoinApp::Application.initialize!

