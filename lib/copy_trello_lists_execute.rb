require 'httparty'
require 'json'

# Load credentials from the credentials file
load File.join(__dir__, 'trello_config.rb')

def get_lists(board_id)
  url = "#{BASE_URL}/boards/#{board_id}/lists?cards=open&key=#{API_KEY}&token=#{API_TOKEN}"
  response = HTTParty.get(url)
  JSON.parse(response.body)
end

def create_list(board_id, name)
  url = "#{BASE_URL}/lists"
  response = HTTParty.post(url, query: {
    key: API_KEY,
    token: API_TOKEN,
    idBoard: board_id,
    name: name,
    pos: "bottom"
  })
  JSON.parse(response.body)
end

def copy_card(card, new_list_id)
  url = "#{BASE_URL}/cards"
  HTTParty.post(url, query: {
    key: API_KEY,
    token: API_TOKEN,
    idList: new_list_id,
    name: card['name'],
    desc: card['desc'],
    due: card['due'],
    idMembers: card['idMembers'].join(','),
    idLabels: card['idLabels'].join(',')
  })
end

def copy_lists_and_cards(source_board_id, destination_board_id)
  puts "🚀 Starting Trello List Copy Process"
  puts "📋 Source Board ID: #{source_board_id}"
  puts "📋 Destination Board ID: #{destination_board_id}"
  puts
  
  source_lists = get_lists(source_board_id)

  if source_lists.empty?
    puts "❌ No lists found in source board"
    return
  end

  puts "📊 Found #{source_lists.length} lists to copy"
  puts

  source_lists.each do |list|
    puts "📋 Copying list: #{list['name']}"
    new_list = create_list(destination_board_id, list['name'])
    
    if list['cards'].empty?
      puts "  ℹ️  No cards in this list"
    else
      puts "  📝 Copying #{list['cards'].length} cards..."
      list['cards'].each do |card|
        puts "    📌 Copying card: #{card['name']}"
        copy_card(card, new_list['id'])
      end
    end
    puts
  end
  
  puts "✅ All lists and cards copied successfully!"
end

def show_usage
  puts "📋 Trello List Copier"
  puts
  puts "Usage:"
  puts "  ruby copy_trello_lists_execute.rb [source_board_id] [destination_board_id]"
  puts
  puts "Examples:"
  puts "  ruby copy_trello_lists_execute.rb"
  puts "    # Uses board IDs from credentials file"
  puts
  puts "  ruby copy_trello_lists_execute.rb abc123 def456"
  puts "    # Uses specified board IDs"
  puts
  puts "  ruby copy_trello_lists_execute.rb --help"
  puts "    # Show this help message"
end

# Main execution
if ARGV.include?('--help') || ARGV.include?('-h')
  show_usage
  exit
end

# Use command line arguments if provided, otherwise use credentials file values
source_board_id = ARGV[0] || SOURCE_BOARD_ID
destination_board_id = ARGV[1] || DESTINATION_BOARD_ID

if source_board_id.nil? || destination_board_id.nil?
  puts "❌ Error: Board IDs not found"
  puts "💡 Please check your credentials file or provide board IDs as arguments"
  puts
  show_usage
  exit 1
end

copy_lists_and_cards(source_board_id, destination_board_id) 