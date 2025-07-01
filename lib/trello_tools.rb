# Trello Tools Library
# Main entry point for all Trello utilities

require_relative 'trello_config'
require_relative 'copy_trello_lists_execute'
require_relative 'archive_trello_lists_by_range'
require_relative 'get_trello_board_id'

module TrelloTools
  VERSION = '1.0.0'
  
  # Main copy lists functionality
  def self.copy_lists(source_board_id = nil, destination_board_id = nil)
    source_board_id ||= SOURCE_BOARD_ID
    destination_board_id ||= DESTINATION_BOARD_ID
    copy_lists_and_cards(source_board_id, destination_board_id)
  end
  
  # Archive lists by number range
  def self.archive_lists_by_range(start_number, end_number, dry_run = false)
    archive_lists_by_number_range(SOURCE_BOARD_ID, start_number, end_number, dry_run)
  end
  
  # Get board ID from URL or name
  def self.get_board_id(input)
    # This would need to be implemented to work as a library method
    # For now, it's available as a command-line tool
    puts "Use the command-line tool: bin/get_trello_board_id"
  end
end 