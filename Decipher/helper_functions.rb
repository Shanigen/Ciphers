module HelperFunctions
  # Finds coprimes to the x
  # @param [Integer] x
  def self.find_coprimes(x)
    coprimes = []
    (1...x).each {|i| coprimes << i if i.gcd(x) == 1}
    return coprimes
  end

  # Performs frequency analysis on the cipher text.
  # @param [String] text
  def self.frequency_analysis(text)
    len = text.size
    count = Hash.new(0)
    frequencies = Hash.new(0)
    text.each_char {|c| count[c] += 1}
    # Perform frequency analysis
    count.each {|c, n| frequencies[c.downcase.to_sym] = ((n.to_f / len) * 100).round 1, half: :down}
    frequencies.sort_by{|_,n| n}.reverse.to_h
  end

  # Calculates index of coincidence of the text.
  # @param [String] text
  def self.ioc(text)
    len = text.size
    count = Hash.new(0)
    ioc = 0
    text.each_char {|c| count[c] += 1}
    count.each {|_, n| ioc += (n * (n - 1)).to_f / (len * (len - 1) / 26).to_f}
    ioc.round(3, half: :down)
  end

  # Implementation of the affine cipher's inverse function.
  # @param [String] alphabet
  # @param [Array] text_ids
  # @param [Integer] a
  # @param [Integer] b
  def self.affine_inverse(alphabet, text_ids, a, b)
    text = ''
    text_ids.each {|c|
      _c = (a * (c - b)) % alphabet.size
      text << alphabet[_c]
    }
    return text
  end
end