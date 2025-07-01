Gem::Specification.new do |spec|
  spec.name          = "trello_tools"
  spec.version       = "1.0.0"
  spec.authors       = ["Your Name"]
  spec.email         = ["your.email@example.com"]
  spec.summary       = "A collection of tools for managing Trello boards"
  spec.description   = "Ruby tools for copying lists, archiving by number range, and extracting board IDs from Trello"
  spec.homepage      = "https://github.com/yourusername/trello_tools"
  spec.license       = "MIT"
  spec.files         = Dir["lib/**/*", "bin/**/*", "config/**/*", "README.md", "LICENSE"]
  spec.executables   = ["copy_trello_lists", "archive_trello_lists", "get_trello_board_id"]
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", "~> 0.21"
  spec.add_dependency "dotenv", "~> 2.8"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end 