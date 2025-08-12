require 'httparty'
require 'json'

# Load credentials from the credentials file
load File.join(__dir__, 'trello_config.rb')

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

def get_full_board_id(board_id_or_short)
  # If it's already a long ID (24 chars), return as-is
  return board_id_or_short if board_id_or_short.length >= 24
  
  # Otherwise, fetch the full board ID from API
  url = "#{BASE_URL}/boards/#{board_id_or_short}?key=#{API_KEY}&token=#{API_TOKEN}"
  response = HTTParty.get(url)
  
  if response.code == 200
    board_data = JSON.parse(response.body)
    board_data['id']
  else
    puts "❌ Error: Could not resolve board ID #{board_id_or_short}"
    puts "   HTTP #{response.code}: #{response.body}"
    nil
  end
end

def get_lists(board_id)
  url = "#{BASE_URL}/boards/#{board_id}/lists?cards=open&key=#{API_KEY}&token=#{API_TOKEN}"
  response = HTTParty.get(url)
  JSON.parse(response.body)
end

def move_list_to_board(list_id, destination_board_id)
  url = "#{BASE_URL}/lists/#{list_id}/idBoard"
  response = HTTParty.put(url, query: {
    key: API_KEY,
    token: API_TOKEN,
    value: destination_board_id
  })
  
  if response.code != 200
    puts "    🔍 Debug: HTTP #{response.code} - #{response.body}"
    puts "    🔍 URL: #{url}"
    puts "    🔍 Destination Board: #{destination_board_id}"
  end
  
  response.code == 200
end

def find_lists_by_pattern(lists, pattern)
  # Find lists that start with the given pattern (case-insensitive)
  matching_lists = lists.select do |list|
    list['name'].downcase.start_with?(pattern.downcase)
  end
  
  matching_lists
end

def move_lists_by_pattern(source_board_id, destination_board_id, pattern, dry_run = false)
  puts "🚀 Starting Trello List Move by Pattern"
  puts "📋 Source Board ID: #{source_board_id}"
  puts "📋 Destination Board ID: #{destination_board_id}"
  puts "🔍 Pattern: Lists starting with '#{pattern}'"
  puts "🔍 Dry run: #{dry_run ? 'Yes' : 'No'}"
  puts
  
  # Resolve full board IDs
  puts "🔄 Resolving board IDs..."
  full_source_id = get_full_board_id(source_board_id)
  full_destination_id = get_full_board_id(destination_board_id)
  
  return unless full_source_id && full_destination_id
  
  puts "✅ Source Board Full ID: #{full_source_id}"
  puts "✅ Destination Board Full ID: #{full_destination_id}"
  puts
  
  source_lists = get_lists(full_source_id)

  if source_lists.empty?
    puts "❌ No lists found in source board"
    return
  end

  matching_lists = find_lists_by_pattern(source_lists, pattern)
  
  if matching_lists.empty?
    puts "❌ No lists found starting with '#{pattern}'"
    puts "📊 Available lists in source board:"
    source_lists.each { |list| puts "  - #{list['name']}" }
    return
  end

  puts "🎯 Found #{matching_lists.length} matching lists:"
  matching_lists.each do |list|
    card_count = list['cards'] ? list['cards'].length : 0
    puts "  - #{list['name']} (#{card_count} cards)"
  end
  puts

  if dry_run
    puts "🔍 This was a dry run. No lists were actually moved."
    puts "💡 Run without --dry-run to actually move the lists."
    return
  end

  puts "⚠️  Are you sure you want to move these lists? This will remove them from the source board! (y/N): "
  confirmation = STDIN.gets.chomp.downcase
  
  if confirmation != 'y' && confirmation != 'yes'
    puts "❌ Operation cancelled."
    return
  end

  puts
  puts "🔄 Moving matching lists..."

  success_count = 0
  failed_count = 0
  total_cards_moved = 0

  matching_lists.each do |list|
    puts "📋 Moving list: #{list['name']}"
    
    begin
      if move_list_to_board(list['id'], full_destination_id)
        card_count = list['cards'] ? list['cards'].length : 0
        total_cards_moved += card_count
        puts "✅ Successfully moved: #{list['name']} (#{card_count} cards)"
        success_count += 1
      else
        puts "❌ Failed to move: #{list['name']}"
        failed_count += 1
      end
    rescue => e
      puts "❌ Failed to move: #{list['name']} - #{e.message}"
      failed_count += 1
    end
    
    puts
  end
  
  puts "🎉 Move operation complete!"
  puts "✅ Successfully moved: #{success_count} lists"
  puts "❌ Failed to move: #{failed_count} lists"
  puts "📌 Total cards moved: #{total_cards_moved}"
end

def show_usage
  puts "📋 Trello List Mover by Name Pattern"
  puts
  puts "Usage:"
  puts "  ruby move_lists_by_name_pattern.rb <source_board_url> <destination_board_url> <pattern> [--dry-run]"
  puts
  puts "Examples:"
  puts "  ruby move_lists_by_name_pattern.rb https://trello.com/b/abc123 https://trello.com/b/def456 'Sprint'"
  puts "    # Moves all lists starting with 'Sprint' (e.g., 'Sprint 1', 'Sprint Planning')"
  puts
  puts "  ruby move_lists_by_name_pattern.rb abc123 def456 'Done' --dry-run"
  puts "    # Shows what lists would be moved without actually doing it"
  puts
  puts "  ruby move_lists_by_name_pattern.rb https://trello.com/b/abc123 def456 'To Do'"
  puts "    # Moves all lists starting with 'To Do' (case-insensitive)"
  puts
  puts "Parameters:"
  puts "  - source_board_url: Source board URL or ID"
  puts "  - destination_board_url: Destination board URL or ID" 
  puts "  - pattern: String that list names should start with"
  puts "  - --dry-run: Optional flag to preview without moving"
  puts
  puts "⚠️  WARNING: This operation moves lists from source to destination board."
  puts "   Lists will be removed from the source board permanently!"
end