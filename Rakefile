require 'rake/testtask'
require 'rspec/core/rake_task'

# Default task
task default: [:test]

# Test task
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["spec/**/*_spec.rb"]
end

# RSpec task
RSpec::Core::RakeTask.new(:spec)

# Install task
task :install do
  puts "Installing Trello Tools..."
  system "gem install #{Dir.glob('*.gemspec').first}"
end

# Setup task
task :setup do
  puts "Setting up Trello Tools..."
  
  # Copy environment template
  unless File.exist?('.env')
    puts "Creating .env file from template..."
    system "cp config/env_example.txt .env"
    puts "Please edit .env with your Trello API credentials"
  end
  
  # Install dependencies
  puts "Installing dependencies..."
  system "bundle install"
  
  puts "Setup complete!"
end

# Clean task
task :clean do
  puts "Cleaning up..."
  FileList["*.gem"].each { |f| File.delete(f) }
  FileList["pkg/**/*"].each { |f| FileUtils.rm_rf(f) }
end 