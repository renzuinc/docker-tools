namespace :project do
  # desc "Generate `.rubocop.local.yml`, `.dockerignore`, and also modify"\
  #   " `Rakefile`, `.gitignore`, etc."\
  #   "  Specify TEMPLATE, or omit for a list of available options."
  task :init do
    # TODO: Generate `.rubocop.local.yml`, utilizing `.rubocop.yml` if it
    # TODO: exists, then remove `.rubocop.yml` from git.
    #
    # TODO: Generate `.dockerignore`, using available gems for guidance.
    #
    # TODO: Based on `TEMPLATE`, generate `Dockerfile`.  Don't forget that for
    # TODO: Alpine, we probably want to add the `tzinfo-data` gem to `Gemfile`!
    #
    # TODO: Modify `Rakefile`.
    #
    # TODO: Modify `.gitignore`.
    #
    # TODO: Generate `WORKFLOW.md`.
  end
end
