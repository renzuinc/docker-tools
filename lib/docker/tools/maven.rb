module Docker
  module Tools
    # Maven helper methods.
    module Maven
      def self.in_use?; File.exist?("pom.xml"); end

      def self.extract_version!
        raw = Nokogiri.parse(File.read("pom.xml"))
        [raw.css("project > artifactId").first.text,
         raw.css("project > version").first.text]
      end

      def self.assets!(*assets)
        @assets = Array(assets)
      end

      def self.assets; @assets; end
    end
  end
end
