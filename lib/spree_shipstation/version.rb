# frozen_string_literal: true

module SpreeShipstation
  module_function

  # Returns the version of the currently loaded SpreeSimpleSales as a
  # <tt>Gem::Version</tt>.
  def version
    Gem::Version.new VERSION::STRING
  end

  module VERSION
    MAJOR = 2
    MINOR = 0
    TINY = 6
    PRE = nil

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join(".")
  end
end
