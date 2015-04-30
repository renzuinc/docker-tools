module Docker
  # A set of helpers for Rake-driven projects, aimed especially at streamlining
  # Docker workflows.
  module Tools
    # Rake helper methods.
    module Rake
      # Create and manage a temp file, replacing `fname` if `fname` is
      # provided.
      def with_tempfile(fname = nil, &block)
        Tempfile.open("tmp") do |f|
          block.call(f.path, f.path.shellescape)
          FileUtils.cp(f.path, fname) unless fname.nil?
        end
      end

      # Show a banner with bars above and below to make it more visually
      # obvious.
      def banner(msg)
        puts "=" * msg.length
        puts msg
        puts "=" * msg.length
      end

      # Define a task named `name` that runs all tasks under an identically
      # named `namespace`.
      def parent_task(name)
        task name do
          ::Rake::Task
            .tasks
            .select { |t| t.name =~ /^#{name}:/ }
            .sort { |a, b| a.name <=> b.name }
            .each(&:execute)
        end
      end
    end
  end
end
