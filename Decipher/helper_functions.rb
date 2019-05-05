module HelperFunctions
  ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.freeze
  LETTER_FREQUENCIES = { a: 8.167, b: 1.492, c: 2.782, d: 4.253, e: 12.702, f: 2.228,
    g: 2.015, h: 6.094, i: 6.966, j: 0.153, k: 0.772, l: 4.025,
    m: 2.406, n: 6.749, o: 7.507, p: 1.929, q: 0.095, r: 5.987,
    s: 6.327, t: 9.056, u: 2.758, v: 0.978, w: 2.360, x: 0.150,
    y: 1.974, z: 0.074 }.freeze
  BIGRAMS_FREQUENCIES = {th: 1.52, en: 0.55, ng: 0.18, he: 1.28, ed: 0.53, of: 0.16,
    in: 0.94, to: 0.52, al: 0.09, er: 0.94, it: 0.50, de: 0.09,
    an: 0.82, ou: 0.50, se: 0.08, re: 0.68, ea: 0.47, le: 0.08,
    nd: 0.63, hi: 0.46, sa: 0.06, at: 0.59, is: 0.46, si: 0.05,
    on: 0.57, or: 0.43, ar: 0.04, nt: 0.56, ti: 0.34, ve: 0.04,
    ha: 0.56, as: 0.33, ra: 0.04, es: 0.56, te: 0.27, ld: 0.02,
    st: 0.55, et: 0.19, ur: 0.02}.freeze
  # Unnormalized IOC, normalization is performed like this: ioc_norm = ioc_unnorm/alphabet_len
  IOC = 1.73
  
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