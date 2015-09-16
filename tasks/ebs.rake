if Docker::Tools::ElasticBeanstalk.in_use?
  namespace :ebs do
    desc "Create a bootstrap version, and push it into the secrets bucket."\
      "  Use this after creating the app in `cnc-renbot`, but before creating any environments."
    task :create_bootstrap do
      sh "zip -9 -r bootstrap.zip Dockerrun.aws.json .ebextensions/"
      puts "WARNING: Placing bootstrap.zip in secrets bucket.  Do a `rake secrets:pull`"\
        " in `cnc-renbot`."
      dest = "elasticbeanstalk-#{Docker::Tools.region}-796425841332/#{Docker::Tools.container}/"
      sh "aws --region #{Docker::Tools.region} s3 cp bootstrap.zip s3://#{dest}"
      # Give it a couple seconds because eventual-consistency...
      sleep 5.0
      sh %(
        aws elasticbeanstalk create-application-version \
          --region #{Docker::Tools.region} \
          --application-name #{Docker::Tools.container} \
          --version-label "bootstrap" \
          --description "Version used to bootstrap environments." \
          --auto-create-application \
          --source-bundle S3Bucket="renzu-keyring",S3Key="#{Docker::Tools.container}/bootstrap.zip"
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
      sh "git commit --message 'Updating Dockerrun.aws.json'"
    end

    # desc "Deploy to EBS."
    # task :deploy do
    # end
  end
end
