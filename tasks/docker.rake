require "erb"
module Docker
  module Tools
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

namespace :docker do
  desc "Build a Docker container from this repo.  "\
    "Use FORCE=1 to bypass layer caching."
  task :build do
    force_rebuild = (ENV["FORCE"].to_i != 0) ? "--no-cache=true" : ""
    sh %(docker build #{force_rebuild} -t #{Docker::Tools.container} .)
    sh %(docker tag -f #{Docker::Tools.container} #{Docker::Tools.latest})
  end

  desc "Tag and push a Docker container from this repo.  Uses VERSION file for"\
    " tag, and accepts FORCE_TAG=1 to forcibly re-tag locally, and FORCE_PUSH"\
    " to forcibly overwrite a tag on the registry."
  task :push do
    force_tag   = (ENV["FORCE_TAG"].to_i != 0) ? "-f " : ""
    force_push  = (ENV["FORCE_PUSH"].to_i != 0) ? "-f " : ""
    remote_name = "#{Docker::Tools.registry}/#{Docker::Tools.full_name}"
    sh %(docker tag #{force_tag}#{Docker::Tools.latest} #{remote_name})
    sh %(docker push #{force_push}#{remote_name})
  end

  desc "Generate `VERSION` `Dockerfile`, `docker-compose.yml`, etc.  Specify"\
    " TEMPLATE, or omit for a list of available options."
  task :init do
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
    # TODO: Generate above-listed files.
    # TODO: Test to see if `docker-compose` is in path, kvetch if not.
  end
end
