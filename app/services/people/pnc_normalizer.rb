module People
  class PncNormalizer
    PNC_REGEX = /\A(\d{2}|\d{4})[\s\/.-]*(\d{1,7})[\s\/.-]*([A-Z])\z/ix

    def self.parse(raw)
      return nil if raw.blank?

      up = raw.to_s.strip.upcase
      match = PNC_REGEX.match(up)
      return nil unless match

      year_raw, num_raw, letter = match.captures

      year2 = year_raw[-2..]
      year4 = year_raw.length == 4 ? year_raw : nil

      num7 = num_raw.rjust(7, '0')

      { year2: year2, year4: year4, num7: num7, letter: letter }
    end

    def self.variants(raw)
      parsed = parse(raw)
      return [] unless parsed

      year2  = parsed[:year2]
      year4  = parsed[:year4]
      num7   = parsed[:num7]
      letter = parsed[:letter]

      variants = []
      variants << "#{year2}/#{num7}#{letter}"

      if year4
        variants << "#{year4}/#{num7}#{letter}"
      else
        variants << "19#{year2}/#{num7}#{letter}"
        variants << "20#{year2}/#{num7}#{letter}"
      end

      variants.uniq
    end
  end
end
