RUBOCOP_HEADING = "# #{('WARNING!  ' * 7).rstrip}\n"\
                  "# AUTO-GENERATED FILE!  DO NOT EDIT DIRECTLY!\n"\
                  "\n"\
                  "# Override from `.rubocop.local.yml` and re-run `rake lint:rubocop` instead!\n"

namespace :lint do
  desc "Run Rubocop against the codebase."
  task :rubocop do
    require "yaml"
    puts "Running Rubocop..."
    defaults_file           = File.expand_path("../../config/rubocop_rules.yml", __FILE__)
    defaults                = YAML.load(File.read(defaults_file))
    local_opts              = ".rubocop.local.yml"
    overrides               = YAML.load(File.read(local_opts)) if File.exist?(local_opts)
    overrides             ||= {}

    # Be slightly intelligent about merging AllCops, but allow overriding things:
    overrides["AllCops"]  ||= {}
    o_allcops               = overrides["AllCops"]
    d_allcops               = defaults["AllCops"] || {}
    o_allcops["Exclude"] ||= d_allcops["Exclude"] if d_allcops.key?("Exclude")
    o_allcops["Include"] ||= d_allcops["Include"] if d_allcops.key?("Include")

    results = (RUBOCOP_HEADING + defaults.merge(overrides).to_yaml).rstrip
    write_file(".rubocop.yml", [results])
    sh "rubocop --display-cop-names"
  end

  desc "Run bundler-audit against the Gemfile."
  task :'bundler-audit' do
    require "bundler/audit/cli"

    %w(update check).each do |command|
      Bundler::Audit::CLI.start [command]
    end
  end

  desc "Show LOC metrics for project using cloc."
  task :cloc do
    # TODO: Make this list customizable.
    sh "cloc . --exclude-dir=notes,secrets,coverage,.bundle,tmp"
  end

  desc "Check for outdated gems."
  task :bundler do
    # Don't error-out if this fails, since we may not be able to update some
    # deps.
    sh "bundle outdated || true"
  end

  # TODO: Add Rubocop task if the Rubocop gem is available.
end

desc "Run all lint checks against the code."
parent_task :lint

task default: [:lint]
