module MagicLink::Code
  # Crockford base32 alphabet: excludes I, L, O and U to avoid characters that
  # are easily confused when a code is typed back in.
  BASE32_ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ".chars

  # Map the excluded look-alikes onto the digits they resemble, so a user who
  # types "O" or "l" still lands on the right code.
  CODE_SUBSTITUTIONS = { "O" => "0", "I" => "1", "L" => "1" }

  class << self
    def generate(length)
      Array.new(length) { BASE32_ALPHABET[SecureRandom.random_number(BASE32_ALPHABET.length)] }.join
    end

    def sanitize(code)
      code.to_s.upcase
        .gsub(/[OIL]/, CODE_SUBSTITUTIONS)
        .gsub(/[^#{BASE32_ALPHABET.join}]/, "")
    end
  end
end
