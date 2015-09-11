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
end
