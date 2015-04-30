desc "Open a Ruby console to Pry."
task :console do
  # rubocop:disable Lint/Debugger
  require "pry"
  binding.pry
  # rubocop:enable Lint/Debugger
end
