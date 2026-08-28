module Bank
  module Auditable
    def audit(message)
      puts "[AUDIT] #{Time.now}: #{message}"
    end
  end
end
