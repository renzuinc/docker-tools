# rubocop:disable Style/Documentation
# Monkey-patch `String` and `Pathname` with some handy-dandy helpers.

class String
  def to_pathname; Pathname.new(self); end
end

class Pathname
  def to_pathname; self; end
end
# rubocop:enable Style/Documentation
