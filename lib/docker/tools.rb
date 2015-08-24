require "pathname"
require "shellwords"
require "erb"

require "rake/clean"
require "active_support/all"
require "nokogiri"

require "docker/monkey_patches"
require "docker/tools/version"
require "docker/tools/rake"

include Docker::Tools::Rake

module Docker
  # A set of helpers for Rake-driven projects, aimed especially at streamlining
  # Docker workflows.
  module Tools
    # Initialize `docker-tools`.  Configures Rake, and loads some handy tasks.
    def self.init!(private_registry = nil, internal_registry = nil)
      @private_registry = private_registry
      @internal_registry  = internal_registry
      # TODO: Pare this to CPU count, or possibly half that because
      # hyperthreading usually is not our friend.
      ::Rake.application.options.thread_pool_size ||= 4
      # Time.zone = 'America/Los_Angeles'

      task_files.each { |fname| load fname }
    end

    def self.registry;          @private_registry; end
    def self.internal_registry; @internal_registry; end
    def self.container;         container_version_info.first; end
    def self.version;           container_version_info.last; end
    def self.full_name;         container_version_info.join(":"); end
    def self.latest;            [container, "latest"].join(":"); end

  protected

    def self.task_files
      task_dir        = File.expand_path("../../../tasks", __FILE__)
      raw_task_files  = FileList["#{task_dir}/**/*.rake"] +
                        FileList["tasks/**/*.rake"]
      raw_task_files
        .map { |fname| File.expand_path(fname) }
        .sort
        .uniq
    end

    def self.container_version_info
      @container_version_info ||= begin
        if File.exist?("VERSION")
          File.read("VERSION").chomp.strip.split(/:/)
        elsif File.exist?("pom.xml")
          raw = Nokogiri.parse(File.read("pom.xml"))
          [ raw.css("project > artifactId").first.text,
            raw.css("project > version").first.text ]
        else
          fail "Couldn't find VERSION or pom.xml.  Giving up!"
        end
      end
    end
  end
end
