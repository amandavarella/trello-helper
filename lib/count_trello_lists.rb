require 'httparty'
require 'json'

# Load credentials and config
load File.join(__dir__, 'trello_config.rb')

def get_lists(board_id)
  url = "#{BASE_URL}/boards/#{board_id}/lists?key=#{API_KEY}&token=#{API_TOKEN}"
  response = HTTParty.get(url)
  JSON.parse(response.body)
end

def archive_list(list_id)
  url = "#{BASE_URL}/lists/#{list_id}/closed"
  response = HTTParty.put(url, query: {
    key: API_KEY,
    token: API_TOKEN,
    value: true
  })
  response.code == 200
end

def show_usage
  puts "Usage: ruby count_trello_lists.rb [BOARD_ID] [--delete-range START_INDEX END_INDEX]"
  puts "If BOARD_ID is not provided, uses SOURCE_BOARD_ID from config."
  puts ""
  puts "Examples:"
  puts "  ruby count_trello_lists.rb                    # Just count and show lists"
  puts "  ruby count_trello_lists.rb --delete-range 10 56  # Delete lists from index 10 to 56"
end

if ARGV.include?('--help') || ARGV.include?('-h')
  show_usage
  exit
end

board_id = ARGV[0] || SOURCE_BOARD_ID
lists = get_lists(board_id)

puts "Board ID: #{board_id}"
puts "Number of lists: #{lists.size}"

if lists.size > 0
  puts "List names:"
  lists.each_with_index do |list, idx|
    puts "  #{idx+1}. #{list['name']}"
  end
end

# Check if delete range is specified
delete_range_index = ARGV.index('--delete-range')
if delete_range_index
  if ARGV.length < delete_range_index + 3
    puts "❌ Error: --delete-range requires START_INDEX and END_INDEX"
    exit 1
  end
  
  start_index = ARGV[delete_range_index + 1].to_i
  end_index = ARGV[delete_range_index + 2].to_i
  
  if start_index < 1 || end_index > lists.size || start_index > end_index
    puts "❌ Error: Invalid range. Must be between 1 and #{lists.size}"
    exit 1
  end
  
  puts ""
  puts "🗑️  About to archive lists from index #{start_index} to #{end_index}:"
  (start_index..end_index).each do |idx|
    list = lists[idx - 1] # Convert to 0-based index
    puts "  #{idx}. #{list['name']}"
  end
  
  puts ""
  puts "⚠️  Are you sure you want to archive these lists? (y/N): "
  print "> "
  confirmation = STDIN.gets.chomp.downcase
  
  if confirmation == 'y' || confirmation == 'yes'
    puts ""
    puts "🔄 Archiving lists..."
    
    success_count = 0
    failed_count = 0
    
    (start_index..end_index).each do |idx|
      list = lists[idx - 1]
      puts "🗑️  Archiving: #{list['name']}"
      
      if archive_list(list['id'])
        puts "✅ Successfully archived: #{list['name']}"
        success_count += 1
      else
        puts "❌ Failed to archive: #{list['name']}"
        failed_count += 1
      end
    end
    
    puts ""
    puts "🎉 Archiving complete!"
    puts "✅ Successfully archived: #{success_count} lists"
    puts "❌ Failed to archive: #{failed_count} lists"
  else
    puts "❌ Operation cancelled."
  end
end 