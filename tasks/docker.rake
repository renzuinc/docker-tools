namespace :docker do
  desc "Build a Docker container from this repo.  "\
    "Use FORCE_BUILD=1 to bypass layer caching."
  task :build do
    force_rebuild = (ENV["FORCE_BUILD"].to_i != 0) ? "--no-cache=true" : ""
    sh %(docker build #{force_rebuild} -t #{Docker::Tools.container} .)
    # sh %(docker tag -f #{Docker::Tools.container} #{Docker::Tools.latest})
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
    force_push  = (ENV["FORCE_PUSH"].to_i != 0) ? "-f " : ""
    remote_name = "#{Docker::Tools.registry}/#{Docker::Tools.full_name}"
    internal_name = "#{Docker::Tools.internal_registry}/#{Docker::Tools.full_name}"
    sh %(docker push #{force_push}#{remote_name})
    if File.exist?("Dockerrun.aws.json")
      puts "Updating Dockerrun.aws.json..."
      raw = JSON.parse(File.read("Dockerrun.aws.json"))
      raw["Image"] ||= {}
      raw["Image"]["Name"] = internal_name
      File.open("Dockerrun.aws.json", "w") do |fh|
        fh.write(JSON.pretty_unparse(raw))
        fh.write("\n")
      end
    end
  end
end
