require 'httparty'
require 'json'
require 'date'

# Load credentials from the credentials file
load File.join(__dir__, 'trello_config.rb')

BASE_URL = "https://api.trello.com/1"

def get_board_lists(board_id)
  url = "#{BASE_URL}/boards/#{board_id}/lists?key=#{API_KEY}&token=#{API_TOKEN}"
  response = HTTParty.get(url)
  
  if response.code == 200
    JSON.parse(response.body)
  else
    puts "❌ Error fetching lists for board #{board_id}: #{response.code}"
    nil
  end
end

def rename_list(list_id, new_name)
  url = "#{BASE_URL}/lists/#{list_id}/name"
  params = {
    value: new_name,
    key: API_KEY,
    token: API_TOKEN
  }
  response = HTTParty.put(url, body: params)
  if response.code == 200
    JSON.parse(response.body)
  else
    puts "❌ Error renaming list #{list_id} to '#{new_name}': #{response.code} - #{response.body}"
    nil
  end
end

def create_list(board_id, list_name, position = "bottom")
  url = "#{BASE_URL}/lists"
  params = {
    name: list_name,
    idBoard: board_id,
    pos: position,
    key: API_KEY,
    token: API_TOKEN
  }
  
  response = HTTParty.post(url, body: params)
  
  if response.code == 200
    JSON.parse(response.body)
  else
    puts "❌ Error creating list '#{list_name}': #{response.code} - #{response.body}"
    nil
  end
end

def move_list_to_board(list_id, dest_board_id)
  url = "#{BASE_URL}/lists/#{list_id}/idBoard"
  params = {
    value: dest_board_id,
    key: API_KEY,
    token: API_TOKEN
  }
  response = HTTParty.put(url, body: params)
  if response.code == 200
    JSON.parse(response.body)
  else
    puts "❌ Error moving list #{list_id} to board #{dest_board_id}: #{response.code} - #{response.body}"
    nil
  end
end

def get_two_weeks_ago_date
  (Date.today - 14).strftime("%Y-%m-%d")
end

def reset_retro_board(start_list_num, end_list_num)
  puts "🔄 Resetting Retrospective Board"
  puts "📅 Using date: #{get_two_weeks_ago_date()}"
  puts "📋 Processing lists #{start_list_num} to #{end_list_num}"
  puts
  
  # Get source board lists
  puts "🔍 Fetching source board lists..."
  source_lists = get_board_lists(SOURCE_BOARD_RETRO_ID)
  
  if source_lists.nil?
    puts "❌ Could not fetch source board lists"
    return false
  end
  
  # Filter lists by number range (1-based indexing)
  selected_lists = source_lists.select.with_index(1) do |list, index|
    index >= start_list_num && index <= end_list_num
  end
  
  if selected_lists.empty?
    puts "❌ No lists found in range #{start_list_num} to #{end_list_num}"
    puts "Available lists:"
    source_lists.each_with_index do |list, index|
      puts "  #{index + 1}. #{list['name']}"
    end
    return false
  end
  
  puts "✅ Found #{selected_lists.length} lists to process:"
  selected_lists.each_with_index do |list, index|
    puts "  #{start_list_num + index}. #{list['name']}"
  end
  puts
  
  # Step 1: Save original names and positions
  original_names = selected_lists.map { |list| list['name'] }
  original_positions = selected_lists.map { |list| list['pos'] }
  
  # Step 2: Rename lists in source board to '<original name> <date>'
  two_weeks_ago = get_two_weeks_ago_date()
  puts "✏️ Renaming lists in source board..."
  selected_lists.each_with_index do |list, idx|
    new_name = "#{original_names[idx]} #{two_weeks_ago}"
    puts "  Renaming '#{list['name']}' to '#{new_name}'"
    rename_list(list['id'], new_name)
  end
  puts

  # Fetch lists again to ensure names are available for new lists
  source_lists = get_board_lists(SOURCE_BOARD_RETRO_ID)

  # Step 3: Create new empty lists in source board with original names and positions
  puts "📝 Creating new empty lists in source board..."
  original_names.each_with_index do |name, idx|
    puts "  Creating: #{name} (at position #{original_positions[idx]})"
    create_list(SOURCE_BOARD_RETRO_ID, name, original_positions[idx])
  end
  puts
  
  # Step 4: Move renamed lists to destination board
  puts "🚚 Moving renamed lists to destination board..."
  selected_lists.each_with_index do |list, idx|
    new_name = "#{original_names[idx]} #{two_weeks_ago}"
    puts "  Moving '#{new_name}' to destination board"
    move_list_to_board(list['id'], DESTINATION_BOARD_RETRO_ID)
  end
  puts
  puts "🎉 Retrospective board reset complete!"
  puts "📊 Summary:"
  puts "  - Renamed and moved #{selected_lists.length} lists to destination board"
  puts "  - Created #{original_names.length} new empty lists in source board"
  puts "  - All lists renamed with date: #{two_weeks_ago}"
  true
end

def show_usage
  puts "🔄 Retrospective Board Reset Tool"
  puts
  puts "Usage:"
  puts "  ruby reset_retro_board.rb <start_list_number> <end_list_number>"
  puts
  puts "Examples:"
  puts "  ruby reset_retro_board.rb 1 3    # Process lists 1, 2, and 3"
  puts "  ruby reset_retro_board.rb 2 4    # Process lists 2, 3, and 4"
  puts
  puts "The script will:"
  puts "  1. Save original names of specified lists from source board (TRELLO_SOURCE_BOARD_RETRO_ID)"
  puts "  2. Rename those lists to '<original_name> <2_weeks_ago_date>'"
  puts "  3. Create new empty lists in source board with the original names"
  puts "  4. Move the renamed lists to the destination board (TRELLO_DESTINATION_BOARD_RETRO_ID)"
  puts
  puts "Required environment variables:"
  puts "  TRELLO_SOURCE_BOARD_RETRO_ID"
  puts "  TRELLO_DESTINATION_BOARD_RETRO_ID"
end

def main
  if ARGV.empty? || ARGV.include?('--help') || ARGV.include?('-h')
    show_usage
    exit
  end
  
  if ARGV.length != 2
    puts "❌ Error: Please provide start and end list numbers"
    puts
    show_usage
    exit 1
  end
  
  start_num = ARGV[0].to_i
  end_num = ARGV[1].to_i
  
  if start_num < 1 || end_num < 1
    puts "❌ Error: List numbers must be positive integers"
    exit 1
  end
  
  if start_num > end_num
    puts "❌ Error: Start number (#{start_num}) must be less than or equal to end number (#{end_num})"
    exit 1
  end
  
  # Check if required environment variables are set
  unless SOURCE_BOARD_RETRO_ID && DESTINATION_BOARD_RETRO_ID
    puts "❌ Error: Missing required environment variables"
    puts "Please set TRELLO_SOURCE_BOARD_RETRO_ID and TRELLO_DESTINATION_BOARD_RETRO_ID in your .env file"
    exit 1
  end
  
  puts "🔧 Configuration:"
  puts "  Source Board ID: #{SOURCE_BOARD_RETRO_ID}"
  puts "  Destination Board ID: #{DESTINATION_BOARD_RETRO_ID}"
  puts
  
  success = reset_retro_board(start_num, end_num)
  exit success ? 0 : 1
end

# Run the script
main 