namespace :docker do
  desc "Build a Docker container from this repo.  "\
    "Use FORCE_BUILD=1 to bypass layer caching."
  task :build do
    force_rebuild = (ENV["FORCE_BUILD"].to_i != 0) ? "--no-cache=true" : ""
    if File.exist?("Dockerfile")
      dest = "."
    elsif File.exist?("context/Dockerfile")
      dest = "context"
    else
      fail "Didn't find a Dockerfile in project root, or context/, cannot proceed."
    end
    sh %(docker build #{force_rebuild} -t #{Docker::Tools.container} #{dest})
  end

  desc "Tag a Docker container from this repo.  Uses VERSION or pom.xml to infer version,"\
    " and accepts FORCE_TAG=1 to forcibly re-tag locally."
  task :tag do
    force_tag   = (ENV["FORCE_TAG"].to_i != 0) ? "-f " : ""
    remote_name = "#{Docker::Tools.registry}/#{Docker::Tools.full_name}"
    sh %(docker tag #{force_tag}#{Docker::Tools.latest} #{remote_name})
  end

  desc "Push the recently tagged Docker container from this repo.  Uses VERSION or pom.xml to"\
    " infer version, and accepts FORCE_PUSH=1 to forcibly overwrite a tag on the registry."
  task :push do
    sh %(docker push #{Docker::Tools.registry}/#{Docker::Tools.full_name})
  end

  desc "Build Docker image for release, tag it, push it to registry.  Must be performed"\
    " immediately after a release build! OR use RELEASE_VERSION=<version>"\
    " to overwrite tag to check out"
  task :release do
    release_tag     = `git tag --list --points-at HEAD^1`.strip
    release_version = release_tag.split(%r{/}).last || (ENV["RELEASE_VERSION"].strip if ENV["RELEASE_VERSION"])
    if release_version.nil? && ENV["RELEASE_VERSION"].nil?
      fail "Tag not found and RELEASE_VERSION is empty. Are you sure this is performed immediately"\
      " after release build? \nIf not be sure to specify RELEASE_VERSION for tag to release from."
    end
    Docker::Tools.override_version = release_version
    puts "Assembling and Releasing version: #{release_version}"
    begin
      sh "git checkout #{release_tag}"
      %i(docker:build docker:tag docker:push).each do |subtask|
        task(subtask).execute
      end
    ensure
      # Try to return to the branch the user was on before we started screwing with their state.
      sh "git checkout -"
    end
  end
end
