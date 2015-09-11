if Docker::Tools::Maven.in_use?
  # Add a `mvn clean release:clean` to the `clean` task.
  task :clean do
    sh "mvn clean release:clean"
  end

  desc "Run the app locally, outside of Docker."
  task :run do
    sh "context/local/bin/launch"
  end

  namespace :mvn do
    desc "Use Maven to build and package the app."
    task :build do
      sh "mvn compile"
    end

    desc "Use Maven to assemble build artifacts for usage/deployment."
    task :assemble do
      sh "mvn package appassembler:assemble"
      jars = FileList["target/*.jar"]
      fail "I'm confused because there isn't exactly 1 jar in target/!" if jars.length != 1
      jar = Pathname.new(jars.first).basename.to_s
      sh "rsync -vcrlpgoD --del target/appassembler/ context/local"
      mv "context/local/repo/#{jar}", "context/local/#{jar}"
      ln_sf "../#{jar}", "context/local/repo/#{jar}"
      cp_r "conf", "context/local/"
      # TODO: Can we suss this out from pom.xml?
      Docker::Tools::Maven.assets.each do |assets|
        cp_r assets, "context/local/"
      end

      cp "bin/launch", "context/local/bin/"
    end

    desc "Run Maven release tasks, update Dockerrun.aws.json, and redo release tag."
    task :release do
      sh "mvn -DpushChanges=false -DremoteTagging=false release:prepare"
      release_tag     = `git tag --list --points-at HEAD^1`.strip
      release_version = release_tag.split(%r{/}).last
      puts "Releasing version: #{release_version}"
      Docker::Tools.override_version = release_version
      sh "git tag -d #{release_tag}"
      task(:'docker:build').execute
      task(:'docker:tag').execute
      task(:'docker:push').execute
      if File.exist?("Dockerrun.aws.json")
        # TODO: This won't pick up the version properly at the moment!!
        puts "Updating Dockerrun.aws.json..."
        internal_registry     = Docker::Tools.internal_registry
        internal_name         = "#{internal_registry}/#{Docker::Tools.full_name}"
        raw                   = JSON.parse(File.read("Dockerrun.aws.json"))
        raw["Image"]        ||= {}
        raw["Image"]["Name"]  = internal_name
        File.open("Dockerrun.aws.json", "w") do |fh|
          fh.write(JSON.pretty_unparse(raw))
          fh.write("\n")
        end

        sh "git commit --message 'Update Dockerrun.aws.json.' -- Dockerrun.aws.json"
      end
      sh %(
        git tag \
          #{release_tag} \
          --message '[maven-release-plugin] prepare release #{release_version}' \
          HEAD
      )
      sh "mvn release:perform"
    end
  end
end
