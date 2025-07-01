# Trello API Credentials and Configuration
# This file loads credentials from environment variables only
# For security, set all values in your .env file or environment

# Load environment variables if dotenv gem is available
begin
  require 'dotenv'
  # Look for .env in project root (parent of lib directory)
  env_path = File.join(__dir__, '..', '.env')
  Dotenv.load(env_path) if File.exist?(env_path)
rescue LoadError
  # dotenv gem not installed, continue without it
end

# API Credentials - prefer environment variables, fallback to defaults
API_KEY = ENV.fetch('TRELLO_API_KEY')
API_TOKEN = ENV.fetch('TRELLO_API_TOKEN')

# Board IDs - prefer environment variables, fallback to defaults
SOURCE_BOARD_ID = ENV['TRELLO_SOURCE_BOARD_ID']
DESTINATION_BOARD_ID = ENV['TRELLO_DESTINATION_BOARD_ID']

# API Base URL
BASE_URL = ENV['TRELLO_BASE_URL'] || "https://api.trello.com/1"
