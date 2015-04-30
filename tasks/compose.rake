if File.exist?("docker-compose.yml")
  namespace :compose do
    desc "Kill the stack, if it's running."
    task :kill do
      sh %(docker-compose kill)
    end

    desc "Nuke the container created by `docker-compose`, with prejudice."
    task :rm do
      sh %(docker-compose rm --force)
    end

    desc "Bring the stack up via Docker Compose.  Be sure to do"\
      " `rake docker:build` first!"
    task :up do
      sh %(docker-compose up)
    end
  end
end
