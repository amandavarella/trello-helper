# Trello Helper - Claude Context

## Project Overview
This is a Ruby gem that provides tools for automating Trello board management. It includes scripts for copying lists, archiving by number range, resetting retrospective boards, and extracting board IDs.

## Key Components

### Main Library Files
- `lib/trello_tools.rb` - Main entry point with module interface
- `lib/trello_config.rb` - Configuration and API credential management
- `lib/copy_trello_lists_execute.rb` - List copying functionality
- `lib/archive_trello_lists_by_range.rb` - Archive lists by number range
- `lib/get_trello_board_id.rb` - Board ID extraction from URLs/names
- `lib/reset_retro_board.rb` - Retrospective board reset functionality

### Executable Scripts (in bin/)
- `copy_trello_lists` - Copy lists between boards
- `archive_trello_lists` - Archive lists by number range
- `get_trello_board_id` - Extract board IDs from URLs or search by name
- `reset_retro_board` - Reset retrospective boards with date renaming

### Configuration
- All configuration uses environment variables loaded from `.env` file
- `config/env_example.txt` - Template for environment variables
- Required: `TRELLO_API_KEY`, `TRELLO_API_TOKEN`
- Optional: `TRELLO_SOURCE_BOARD_ID`, `TRELLO_DESTINATION_BOARD_ID`

## Dependencies
- `httparty` - HTTP client for Trello API requests
- `dotenv` - Environment variable management
- `json` - JSON parsing

## Common Tasks

### Setup
```bash
rake setup  # Creates .env file and installs dependencies
bundle install  # Install gem dependencies
```

### Testing
```bash
rake test  # Run tests
rake spec  # Run RSpec tests
```

### Installation
```bash
rake install  # Install as system gem
```

### Usage Examples
```bash
# Copy lists between boards
bin/copy_trello_lists

# Archive lists 1-5
bin/archive_trello_lists 1 5

# Get board ID from URL
bin/get_trello_board_id "https://trello.com/b/abc123/board-name"

# Reset retrospective board (lists 3-6)
bin/reset_retro_board 3 6
```

## Security Notes
- API credentials are stored in `.env` file (gitignored)
- Never commit API keys or tokens
- All sensitive data loaded from environment variables

## Project Structure
```
trello-helper/
├── lib/                  # Main library code
├── bin/                  # Executable scripts
├── config/              # Configuration templates
├── spec/                # Tests
├── Gemfile              # Dependencies
├── trello_tools.gemspec # Gem specification
└── Rakefile            # Build tasks
```

## Development
- Ruby >= 3.1.2 required
- Uses standard Ruby gem structure
- Tests should be in `spec/` directory
- Command-line tools are thin wrappers around library functions