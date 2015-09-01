# TODO: Push this into `docker-tools`.
if Docker::Tools::Maven.in_use?
  namespace :mvn do
    desc "Use Maven to clean build artifacts."
    task :clean do
      sh "mvn clean"
    end

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

    task :run do
      sh "context/local/bin/launch"
    end

    # TODO: Tagging and releasing.  Be sure to update pom.xml, Dockerrun.aws.json, etc.
    #
    # TODO: Drive the EB region setting from .env!
    task :prerelease do
    end

    task :tag do
      sh "git tag release/"
    end
  end
end
