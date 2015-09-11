module Docker
  module Tools
    # Elastic Beanstalk helper methods.
    module ElasticBeanstalk
      def self.in_use?; Dir.exist?(".elasticbeanstalk"); end
    end
  end
end
