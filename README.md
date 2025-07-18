# 📋 Trello Helper (Ruby Scripts)

This project provides a set of Ruby scripts to help you work with Trello boards, lists, and cards using the Trello API. It includes tools for copying lists, archiving lists, resetting retrospective boards, and extracting board IDs from Trello URLs or names.

## 🚀 Features

- Copy all lists (columns) and their cards from one Trello board to another
- Archive lists by number range
- Reset retrospective boards by copying and renaming lists with dates
- Extract Trello board IDs (outputs both the short ID from the URL and the full ID from the API)
- Helper functions for Trello automation

## 🔧 Requirements

- macOS or Unix-based system
- Ruby ≥ 3.1.2 (tested with 3.4.3)
- Trello account with access to relevant boards

## 💎 Install Ruby (via rbenv)

```bash
# 1. Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install rbenv and ruby-build
brew install rbenv ruby-build

# 3. Add rbenv to your shell config (for Zsh users)
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
source ~/.zshrc

# 4. Install Ruby
rbenv install 3.4.3
rbenv global 3.4.3

# 5. Verify Ruby version
ruby -v
```

## 📦 Install Dependencies

```bash
# Install bundler if you don't have it
gem install bundler

# Install all dependencies
bundle install
```

## 🔐 Trello API Setup

1. **Get your API Key**  
   👉 [https://trello.com/power-ups/admin/](https://trello.com/power-ups/admin/)  
   - Click **"Create a new Power-Up"** if needed  
   - Your **API Key** will be shown under the "API Key" column  

2. **Generate your OAuth Token**  
   Replace `<your_api_key>` below with your actual API key and visit:

   ```
   https://trello.com/1/authorize?key=<your_api_key>&name=TrelloHelper&expiration=never&response_type=token&scope=read,write
   ```

   - Click **Allow**
   - Copy the token that appears

3. **Add your credentials** (required):

### Environment Variables (Required)
Create a `.env` file in the project root (this file is gitignored):
```bash
cp config/env_example.txt .env
```

Then edit `.env` with your actual credentials:
```env
TRELLO_API_KEY=your_api_key
TRELLO_API_TOKEN=your_generated_token
TRELLO_SOURCE_BOARD_ID=your_source_board_id
TRELLO_DESTINATION_BOARD_ID=your_destination_board_id
TRELLO_SOURCE_BOARD_RETRO_ID=your_retro_source_board_id
TRELLO_DESTINATION_BOARD_RETRO_ID=your_retro_destination_board_id
```

**All configuration is loaded from environment variables. There are no hardcoded defaults.**

## 🔍 Get Your Board IDs Easily

You can use the provided script to extract both the short and full board IDs from a Trello board URL:

```bash
bin/get_trello_board_id "https://trello.com/b/abc123/board-name"
```

Example output:
```
🎯 Board IDs for use in scripts:
SHORT_ID = "abc123"
FULL_BOARD_ID = "6811c0bb045afc31527"
BOARD_ID = "abc123" # (short, from URL) or 6811c0bb045afc31527 (full, from API)
```

You can also search by board name:
```bash
bin/get_trello_board_id "My Project Board"
```

## ▶️ Run the Scripts

### Command Line Tools
```bash
# Copy lists between boards
bin/copy_trello_lists

# Archive lists by number range
bin/archive_trello_lists 1 5

# Get board ID from URL or name
bin/get_trello_board_id "https://trello.com/b/abc123/board-name"

# Reset retrospective board
bin/reset_retro_board 3 6
```

### As a Library
```ruby
require 'trello_tools'

# Copy lists
TrelloTools.copy_lists

# Archive lists by range
TrelloTools.archive_lists_by_range(1, 5, dry_run: true)
```

### Setup
```bash
# Initial setup
rake setup

# Install as a gem
rake install
```

## 📁 Project Structure

```
trello-helper/
├── lib/                           # Main library code
│   ├── trello_config.rb           # Configuration and credentials
│   ├── trello_tools.rb            # Main library entry point
│   ├── copy_trello_lists_execute.rb
│   ├── archive_trello_lists_by_range.rb
│   ├── get_trello_board_id.rb
│   └── reset_retro_board.rb
├── bin/                          # Executable scripts
│   ├── copy_trello_lists
│   ├── archive_trello_lists
│   ├── get_trello_board_id
│   └── reset_retro_board
├── config/                       # Configuration files
│   └── env_example.txt
├── spec/                         # Tests (to be added)
├── Gemfile                       # Ruby dependencies
├── trello_tools.gemspec          # Gem specification
├── Rakefile                      # Build tasks
├── .gitignore                    # Excludes .env and other files
└── README.md                     # This file
```

## ✅ Example Output

```text
Copying list: For the Manager
  Copying card: Define Q2 objectives
  Copying card: Finalise roadmap
✅ All lists and cards copied!
```

## 🧹 Troubleshooting

- ❗ `invalid value for idBoard` → Make sure your `DESTINATION_BOARD_ID` is correct
- ❗ `JSON::ParserError` → Print `response.body` before parsing to debug Trello API responses
- ❗ `multi_xml requires Ruby >= 3.1.2` → Use `rbenv` to upgrade Ruby as shown above

## 🛠️ Additional Scripts

This repository includes multiple Trello utilities:

### 📦 Archive Lists by Number Range
```bash
# Archive lists with numbers 1-5
bin/archive_trello_lists 1 5

# Test what would be archived (dry run)
bin/archive_trello_lists 1 5 --dry-run
```

### 🔍 Get Board ID from URL or Name
```bash
# Extract board ID from URL (outputs both short and full IDs)
bin/get_trello_board_id "https://trello.com/b/abc123/board-name"

# Search by board name
bin/get_trello_board_id "My Project Board"
```

### 🔄 Reset Retrospective Board
```bash
# Reset lists 3 to 6 for retrospective
bin/reset_retro_board 3 6
```

The reset retrospective board script will:
1. Save the original names of the specified lists from the source board
2. Rename those lists to `<original_name> <2_weeks_ago_date>`
3. Create new empty lists in the source board with the original names
4. Move the renamed lists to the destination board

**Required environment variables:**
- `TRELLO_SOURCE_BOARD_RETRO_ID` - The source retrospective board ID
- `TRELLO_DESTINATION_BOARD_RETRO_ID` - The destination board ID for archived lists

Example output:
```text
🔄 Resetting Retrospective Board
📅 Using date: 2025-01-03
📋 Processing lists 3 to 6
✅ Found 4 lists to process:
  3. To dos
  4. What went well
  5. What could have gone better?
  6. I am puzzled about

✏️ Renaming lists in source board...
📝 Creating new empty lists in source board...
🚚 Moving renamed lists to destination board...

🎉 Retrospective board reset complete!
📊 Summary:
  - Renamed and moved 4 lists to destination board
  - Created 4 new empty lists in source board
  - All lists renamed with date: 2025-01-03
```

## 🔒 Security

- The `.env` file is included in `.gitignore` and will not be committed to the repository.
- Never share your API key or token publicly.

---

Enjoy automating your Trello workflows! 🎉

