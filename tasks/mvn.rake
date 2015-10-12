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

    desc "Run Maven release tasks, producing a release-ready build."
    task release: [:clean] do
      # Note that these tasks do NOT package/assemble the app -- and they operate by doing a
      # `git clone` to a separate location.  So basically the tasks won't find the binaries it
      # build without some nasty shuffling of files.  Instead, we treat it like a black box by just
      # doing the build again from scratch.
      sh "mvn release:prepare release:perform"
      release_tag     = `git tag --list --points-at HEAD^1`.strip
      release_version = release_tag.split(%r{/}).last
      Docker::Tools.override_version = release_version
      puts "Assembling and Releasing version: #{release_version}"
      begin
        sh "git checkout #{release_tag}"
        %i(clean mvn:build mvn:assemble).each do |subtask|
          task(subtask).execute
        end
      ensure
        # Try to return to the branch the user was on before we started screwing with their state.
        sh "git checkout -"
      end
    end
  end
end
