require 'httparty'
require 'json'
require 'uri'

# Load credentials from the credentials file
load 'trello_config.rb'

BASE_URL = "https://api.trello.com/1"

def extract_board_id_from_url(board_url)
  # Handle different Trello URL formats
  patterns = [
    # https://trello.com/b/BOARD_ID/board-name
    /trello\.com\/b\/([a-zA-Z0-9]+)/,
    # https://trello.com/board/BOARD_ID/board-name
    /trello\.com\/board\/([a-zA-Z0-9]+)/,
    # Just the board ID itself
    /^([a-zA-Z0-9]{8,})$/
  ]
  
  patterns.each do |pattern|
    match = board_url.match(pattern)
    return match[1] if match
  end
  
  nil
end

def get_board_details(board_id)
  url = "#{BASE_URL}/boards/#{board_id}?key=#{API_KEY}&token=#{API_TOKEN}"
  response = HTTParty.get(url)
  
  if response.code == 200
    JSON.parse(response.body)
  else
    nil
  end
end

def get_board_id_from_name(board_name)
  # Get all boards for the authenticated user
  url = "#{BASE_URL}/members/me/boards?key=#{API_KEY}&token=#{API_TOKEN}"
  response = HTTParty.get(url)
  
  if response.code == 200
    boards = JSON.parse(response.body)
    
    # Find board by name (case-insensitive)
    board = boards.find { |b| b['name'].downcase == board_name.downcase }
    return board['id'] if board
    
    # If exact match not found, show similar matches
    similar_boards = boards.select { |b| b['name'].downcase.include?(board_name.downcase) }
    if similar_boards.any?
      puts "❌ Exact match not found, but found similar boards:"
      similar_boards.each do |b|
        puts "  - #{b['name']} (ID: #{b['id']})"
      end
    end
  end
  
  nil
end

def display_board_info(board_data)
  puts "📋 Board Information:"
  puts "  Name: #{board_data['name']}"
  puts "  ID: #{board_data['id']}"
  puts "  URL: #{board_data['url']}"
  puts "  Description: #{board_data['desc'] || 'No description'}"
  puts "  Closed: #{board_data['closed'] ? 'Yes' : 'No'}"
  puts "  Pinned: #{board_data['pinned'] ? 'Yes' : 'No'}"
  puts "  Starred: #{board_data['starred'] ? 'Yes' : 'No'}"
  puts "  Members: #{board_data['memberships']&.length || 0}"
  puts "  Lists: #{board_data['lists']&.length || 0}"
  puts "  Cards: #{board_data['cards']&.length || 0}"
end

def show_usage
  puts "🔍 Trello Board ID Extractor"
  puts
  puts "Usage:"
  puts "  ruby get_trello_board_id.rb <board_url_or_name>"
  puts
  puts "Examples:"
  puts "  ruby get_trello_board_id.rb https://trello.com/b/abc123/board-name"
  puts "  ruby get_trello_board_id.rb abc123"
  puts "  ruby get_trello_board_id.rb \"My Project Board\""
  puts
  puts "The script will:"
  puts "  1. Extract board ID from URL if provided"
  puts "  2. Search by board name if no URL pattern found"
  puts "  3. Display detailed board information"
  puts "  4. Show the board ID for use in other scripts"
end

def main
  if ARGV.empty? || ARGV.include?('--help') || ARGV.include?('-h')
    show_usage
    exit
  end
  
  input = ARGV[0]
  
  if input.nil? || input.strip.empty?
    puts "❌ Error: Please provide a board URL or name"
    puts
    show_usage
    exit 1
  end
  
  puts "🔍 Searching for Trello board..."
  puts "📝 Input: #{input}"
  puts
  
  # Try to extract board ID from URL first
  board_id = extract_board_id_from_url(input)
  
  if board_id
    puts "✅ Found board ID in URL: #{board_id}"
    board_data = get_board_details(board_id)
    
    if board_data
      puts
      display_board_info(board_data)
      puts
      puts "🎯 Board ID for use in scripts:"
      puts "BOARD_ID = \"#{board_id}\""
    else
      puts "❌ Could not fetch board details. Possible reasons:"
      puts "   - Board ID is invalid"
      puts "   - You don't have access to this board"
      puts "   - API credentials are incorrect"
    end
  else
    puts "🔍 No board ID found in URL, searching by name..."
    board_id = get_board_id_from_name(input)
    
    if board_id
      puts "✅ Found board by name: #{input}"
      board_data = get_board_details(board_id)
      
      if board_data
        puts
        display_board_info(board_data)
        puts
        puts "🎯 Board ID for use in scripts:"
        puts "BOARD_ID = \"#{board_id}\""
      end
    else
      puts "❌ Could not find board with name: #{input}"
      puts
      puts "💡 Try:"
      puts "   - Using the full Trello board URL"
      puts "   - Checking the exact board name"
      puts "   - Verifying you have access to the board"
    end
  end
end

# Run the script
main 