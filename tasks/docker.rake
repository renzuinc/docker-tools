namespace :docker do
  desc "Build a Docker container from this repo.  "\
    "Use FORCE_BUILD=1 to bypass layer caching."
  task :build do
    force_rebuild = (ENV["FORCE_BUILD"].to_i != 0) ? "--no-cache=true" : ""
    sh %(docker build #{force_rebuild} -t #{Docker::Tools.container} #{Docker::Tools.path})
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
end
