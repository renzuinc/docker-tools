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

      # Write an array of strings to a file, adding newline separators, and
      # ensuring a trailing newline at the end of a file.
      def write_file(file_name, file_contents)
        File.open(file_name, "w") do |fh|
          fh.write(file_contents.flatten.select { |line| line }.join("\n"))
          fh.write("\n")
        end
      end

      # Filter through the contents of a file, matching against a line and
      # modifying/removing/replacing matching lines.
      def filter_file!(file_name, &line_handler)
        file_contents = File
                        .readlines(file_name)
                        .map(&:chomp)
                        .map do |line|
                          res = line_handler.call(line)
                          res = line if res.nil?
                          res
                        end
        write_file(file_name, file_contents)
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
