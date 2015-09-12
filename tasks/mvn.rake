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
    task release: [:clean] do
      sh "mvn release:prepare release:perform"
      release_tag     = `git tag --list --points-at HEAD^1`.strip
      release_version = release_tag.split(%r{/}).last
      puts "Releasing version: #{release_version}"
      Docker::Tools.override_version = release_version
      task(:'docker:build').execute
      task(:'docker:tag').execute
      task(:'docker:push').execute
    end
  end
end
