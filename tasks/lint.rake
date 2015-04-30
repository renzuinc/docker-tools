namespace :lint do
  desc "Run Rubocop against the codebase."
  task :rubocop do
    require "yaml"
    puts "Running Rubocop..."
    defaults_file = File.expand_path("../../config/rubocop_rules.yml", __FILE__)
    defaults      = YAML.load(File.read(defaults_file))
    overrides     = YAML.load(File.read(".rubocop.local.yml"))
    heading       = "# #{('WARNING!  ' * 7).rstrip}\n"\
                      "# AUTO-GENERATED FILE!  DO NOT EDIT DIRECTLY!\n"\
                      "\n"\
                      "# Override from `.rubocop.local.yml` and run `rake"\
                        " lint` again, instead!\n"
    # TODO: Merge `AllCops` more intelligently?
    results       = (heading + defaults.merge(overrides).to_yaml).rstrip
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

  # TODO: maybe also include `bundle outdated` as a lint?
end

desc "Run all lint checks against the code."
parent_task :lint

task default: [:lint]
