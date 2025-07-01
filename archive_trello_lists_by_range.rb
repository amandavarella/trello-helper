require 'httparty'
require 'json'

# Load credentials from the credentials file
load 'trello_config.rb'

BASE_URL = "https://api.trello.com/1"

def get_lists(board_id)
  url = "#{BASE_URL}/boards/#{board_id}/lists?cards=open&key=#{API_KEY}&token=#{API_TOKEN}"
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

def extract_number_from_list_name(list_name)
  # Extract numbers from list names like "Sprint 1", "Week 5", "Task 10", etc.
  # This regex looks for numbers that appear after common prefixes
  match = list_name.match(/(?:sprint|week|task|epic|story|bug|feature|list|column)\s*(\d+)/i)
  match ? match[1].to_i : nil
end

def archive_lists_by_number_range(board_id, start_number, end_number, dry_run = false)
  lists = get_lists(board_id)
  lists_to_archive = []
  
  puts "🔍 Scanning board for lists with numbers #{start_number} to #{end_number}..."
  puts "📋 Found #{lists.length} total lists"
  puts
  
  lists.each do |list|
    number = extract_number_from_list_name(list['name'])
    if number && number >= start_number && number <= end_number
      lists_to_archive << list
      status = dry_run ? "🔍 [DRY RUN] Would archive" : "📦 Will archive"
      puts "#{status}: #{list['name']} (number: #{number})"
    end
  end
  
  if lists_to_archive.empty?
    puts "❌ No lists found with numbers in range #{start_number}-#{end_number}"
    return
  end
  
  puts
  puts "📊 Summary: #{lists_to_archive.length} lists to archive"
  
  if dry_run
    puts "🔍 This was a dry run. No lists were actually archived."
    puts "💡 Run without --dry-run to actually archive the lists."
    return
  end
  
  puts
  puts "⚠️  Are you sure you want to archive these lists? (y/N): "
  confirmation = gets.chomp.downcase
  
  if confirmation != 'y' && confirmation != 'yes'
    puts "❌ Operation cancelled."
    return
  end
  
  puts
  puts "🔄 Archiving lists..."
  
  success_count = 0
  failed_count = 0
  
  lists_to_archive.each do |list|
    puts "📦 Archiving: #{list['name']}"
    if archive_list(list['id'])
      puts "✅ Successfully archived: #{list['name']}"
      success_count += 1
    else
      puts "❌ Failed to archive: #{list['name']}"
      failed_count += 1
    end
  end
  
  puts
  puts "🎉 Archiving complete!"
  puts "✅ Successfully archived: #{success_count} lists"
  puts "❌ Failed to archive: #{failed_count} lists"
end

def show_usage
  puts "📋 Trello List Archiver by Number Range"
  puts
  puts "Usage:"
  puts "  ruby archive_trello_lists_by_range.rb <start_number> <end_number> [--dry-run]"
  puts
  puts "Examples:"
  puts "  ruby archive_trello_lists_by_range.rb 1 5"
  puts "    # Archives lists with numbers 1-5 (e.g., 'Sprint 1', 'Week 3')"
  puts
  puts "  ruby archive_trello_lists_by_range.rb 10 20 --dry-run"
  puts "    # Shows what would be archived without actually doing it"
  puts
  puts "Supported list name patterns:"
  puts "  - Sprint 1, Sprint 2, etc."
  puts "  - Week 1, Week 2, etc."
  puts "  - Task 1, Task 2, etc."
  puts "  - Epic 1, Epic 2, etc."
  puts "  - Story 1, Story 2, etc."
  puts "  - Bug 1, Bug 2, etc."
  puts "  - Feature 1, Feature 2, etc."
  puts "  - List 1, List 2, etc."
  puts "  - Column 1, Column 2, etc."
end

# Main execution
if ARGV.empty? || ARGV.include?('--help') || ARGV.include?('-h')
  show_usage
  exit
end

if ARGV.length < 2
  puts "❌ Error: Please provide start and end numbers"
  puts
  show_usage
  exit 1
end

start_number = ARGV[0].to_i
end_number = ARGV[1].to_i
dry_run = ARGV.include?('--dry-run')

if start_number <= 0 || end_number <= 0
  puts "❌ Error: Start and end numbers must be positive integers"
  exit 1
end

if start_number > end_number
  puts "❌ Error: Start number must be less than or equal to end number"
  exit 1
end

puts "🚀 Starting Trello List Archiver"
puts "📊 Range: #{start_number} to #{end_number}"
puts "🔍 Dry run: #{dry_run ? 'Yes' : 'No'}"
puts

archive_lists_by_number_range(SOURCE_BOARD_ID, start_number, end_number, dry_run) 