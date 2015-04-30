require "pathname"
require "shellwords"
require "erb"

require "rake/clean"
require "active_support/all"

require "docker/monkey_patches"
require "docker/tools/version"
require "docker/tools/rake"

include Docker::Tools::Rake

module Docker
  # A set of helpers for Rake-driven projects, aimed especially at streamlining
  # Docker workflows.
  module Tools
    # Initialize `docker-tools`.  Configures Rake, and loads some handy tasks.
    def self.init!(private_registry = nil)
      @private_registry = private_registry
      # Pare this to CPU count, or possibly half that because hyperthreading
      # usually is not our freind.
      ::Rake.application.options.thread_pool_size ||= 4
      # Time.zone = 'America/Los_Angeles'

      task_dir = File.expand_path("../../../tasks", __FILE__)
      FileList["#{task_dir}/**/*.rake"].each { |fname| load fname }

      FileList["tasks/**/*.rake"].each { |fname| load fname }
    end

    def self.registry;  @private_registry; end
    def self.container; container_version_info.first; end
    def self.version;   container_version_info.last; end
    def self.full_name; container_version_info.join(":"); end
    def self.latest;    [container, "latest"].join(":"); end

  protected

    def self.container_version_info
      @container_version_info ||= File.read("VERSION").chomp.strip.split(/:/)
    end
  end
end
