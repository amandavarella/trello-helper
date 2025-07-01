# 📋 Trello List Copier (Ruby Script)

This Ruby script copies all lists (columns) and their cards from one Trello board (source) to another (destination) using the Trello API.

## 🚀 Features

- Copies all lists (columns) from a source board
- Copies all cards within each list
- Preserves card metadata like due dates, members, and labels

## 🔧 Requirements

- macOS or Unix-based system
- Ruby ≥ 3.1.2 (tested with 3.4.3)
- Trello account with access to both source and destination boards

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

### Option 1: Install gems individually
```bash
gem install httparty
gem install dotenv
```

### Option 2: Use Bundler (recommended)
```bash
# Install bundler if you don't have it
gem install bundler

# Install all dependencies
bundle install
```

## 🔐 Trello API Setup

1. **Get your API Key**  
   👉 [https://trello.com/power-ups/admin/](https://trello.com/power-ups/admin/)  
   - Click **“Create a new Power-Up”** if needed  
   - Your **API Key** will be shown under the “API Key” column  

2. **Generate your OAuth Token**  
   Replace `<your_api_key>` below with your actual API key and visit:

   ```
   https://trello.com/1/authorize?key=<your_api_key>&name=TrelloListCopier&expiration=never&response_type=token&scope=read,write
   ```

   - Click **Allow**
   - Copy the token that appears

3. **Add your credentials** (required):

### Environment Variables (Required)
Create a `.env` file in the project root:
```bash
cp config/env_example.txt .env
```

Then edit `.env` with your actual credentials:
```env
TRELLO_API_KEY=your_api_key
TRELLO_API_TOKEN=your_generated_token
TRELLO_SOURCE_BOARD_ID=your_source_board_id
TRELLO_DESTINATION_BOARD_ID=your_destination_board_id
```

**All configuration is now loaded from environment variables. There are no hardcoded defaults.**

## �� Get Your Board IDs

Visit this URL with your key and token:

```
https://api.trello.com/1/members/me/boards?key=YOUR_API_KEY&token=YOUR_API_TOKEN
```

Find the board names and use the corresponding `"id"` values:

```ruby
SOURCE_BOARD_ID = "6811c0bb0c4d45b8afc31527"
DESTINATION_BOARD_ID = "6811c0cffbf90e67a97b275c"
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
trello_tools/
├── lib/                           # Main library code
│   ├── trello_config.rb          # Configuration and credentials
│   ├── trello_tools.rb           # Main library entry point
│   ├── copy_trello_lists_execute.rb
│   ├── archive_trello_lists_by_range.rb
│   └── get_trello_board_id.rb
├── bin/                          # Executable scripts
│   ├── copy_trello_lists
│   ├── archive_trello_lists
│   └── get_trello_board_id
├── config/                       # Configuration files
│   └── env_example.txt
├── spec/                         # Tests (to be added)
├── Gemfile                       # Ruby dependencies
├── trello_tools.gemspec         # Gem specification
├── Rakefile                     # Build tasks
└── README.md                    # This file
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

This repository also includes additional Trello utilities:

### 📦 Archive Lists by Number Range
```bash
# Archive lists with numbers 1-5
ruby archive_trello_lists_by_range.rb 1 5

# Test what would be archived (dry run)
ruby archive_trello_lists_by_range.rb 1 5 --dry-run
```

### 🔍 Get Board ID from URL
```bash
# Extract board ID from URL
ruby get_trello_board_id.rb https://trello.com/b/abc123/board-name

# Search by board name
ruby get_trello_board_id.rb "My Project Board"
```

