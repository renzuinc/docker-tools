namespace :lint do
  desc "Run Rubocop against the codebase."
  task :rubocop do
    puts "Running Rubocop..."
    sh "rubocop --display-cop-names"
  end

  desc "Run bundler-audit against the Gemfile."
  task :'bundler-audit' do
    require "bundler/audit/cli"

    %w(update check).each do |command|
      Bundler::Audit::CLI.start [command]
    end
  end

  # TODO: maybe also include `bundle outdated` as a lint?
end

desc "Run all lint checks against the code."
parent_task :lint

task default: [:lint]
