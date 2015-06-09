require "erb"
module Docker
  module Tools
    # Helpers to assist with doing templated file generation.
    class Templating
      def config_dir
        @config_dir ||= File.expand_path("../../config", __FILE__).to_pathname
      end

      def valid_template?(name)
        Dir.exist?(config_dir + name)
      end

      def maintainer_guess
        @maintainer_guess ||= `git config user.name 2>/dev/null`.strip
      end

      def templates
        @templates  ||= FileList[config_dir + "**"]
                        .select { |dir| Dir.exist?(dir) }
                        .map(&:to_pathname)
                        .map(&:basename)
                        .map(&:to_s)
                        .reject { |dir| dir == "default" }
      end

      def template(name, file)
        ERB.new(File.read((config_dir + name) + file), nil, "-")
      end

      def project_name_guess
        @project_name_guess ||= Dir.pwd.to_pathname.basename.to_s
      end

      def project_name
        if File.exist?("VERSION")
          @project_name_real ||= File.read("VERSION").split(/:/).first
        else
          project_name_guess
        end
      end

      def safe_create(fname, &block)
        if !File.exist?(fname)
          puts "#{fname}: Creating."
          contents = Array(block.call).compact.join("\n").rstrip + "\n"
          File.open(fname, "w") do |fh|
            fh.write(contents)
          end
        else
          puts "#{fname}: Already exists.  Skipping."
        end
      end
    end
  end
end

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

    tools     = Docker::Tools::Templating.new
    template  = ENV["TEMPLATE"]
    if template.present?
      fail "Invalid value for TEMPLATE!" unless tools.valid_template?(template)
    else
      puts "Available TEMPLATE values:"
      tools.templates.each do |name|
        puts "  #{name}"
      end
      next
    end

    tools.safe_create("VERSION") do
      "#{tools.project_name_guess}:0.0.0"
    end

    tools.safe_create("Dockerfile") do
      tools.template(template, "Dockerfile.erb").result(binding)
    end

    tools.safe_create("docker-compose.yml") do
    end
  end
end
