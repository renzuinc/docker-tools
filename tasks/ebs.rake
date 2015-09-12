if Docker::Tools::ElasticBeanstalk.in_use?
  namespace :ebs do
    desc "Create a bootstrap version, and push it into the secrets bucket."\
      "  Use this after creating the app in `cnc-renbot`, but before creating any environments."
    task create_bootstrap: [:'mvn:clean', :'mvn:build', :'mvn:assemble', :'docker:build',
                            :'mvn:release:update_versions', :'docker:build', :'docker:tag',
                            :'docker:push', :'mvn:release:perform'] do
      sh "zip -9 -r bootstrap.zip Dockerrun.aws.json .ebextensions/"
      puts "WARNING: Placing bootstrap.zip in secrets bucket.  Do a `rake secrets:pull`"\
        " in `cnc-renbot`."
      sh "aws --region us-west-2 s3 cp bootstrap.zip s3://renzu-keyring/cecil-api/"
      sh %q(
        aws elasticbeanstalk create-application-version \
          --region us-west-2 \
          --application-name cecil-api \
          --version-label "bootstrap" \
          --description "Version used to bootstrap environments." \
          --auto-create-application \
          --source-bundle S3Bucket="renzu-keyring",S3Key="cecil-api/bootstrap.zip"
      )
    end

    task :update_dockerrun do
      puts "Updating Dockerrun.aws.json..."
      # TODO: Bitch if the name ends with `-SNAPSHOT`...
      internal_registry     = Docker::Tools.internal_registry
      internal_name         = "#{internal_registry}/#{Docker::Tools.full_name}"
      raw                   = JSON.parse(File.read("Dockerrun.aws.json"))
      raw["Image"]        ||= {}
      raw["Image"]["Name"]  = internal_name
      File.open("Dockerrun.aws.json", "w") do |fh|
        fh.write(JSON.pretty_unparse(raw))
        fh.write("\n")
      end
      sh "git add -- Dockerrun.aws.json"
      sh "git commit --message AUGH"
    end

    # desc "Deploy to EBS."
    # task :deploy do
    # end
  end
end
