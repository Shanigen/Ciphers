require '../Decipher/helper_functions'
require 'matrix'

class TranspositionCipher
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

  def self.find_best(text, sizes)
    # File.open('transpose_cipher', 'w') { |file|
    sizes.each do |dims|
      p dims
      m = Matrix.build(dims[0], dims[1]) { |row, col| text[col * dims[0] + row] }
      p (0...dims[1]).to_a.join(",").split(",")
      m.each_slice(m.column_size) {|r| p r}
      perms = (0...dims[1]).to_a.permutation(2).to_a

      cols_pairs = {}
      perms.each do |cols_ids|
        bigrams_freq = 0
        (0...dims[0]).each do |i|
          bigram = [m.element(i, cols_ids[0]), m.element(i, cols_ids[1])].join.downcase.to_sym
          bigrams_freq += BIGRAMS_FREQUENCIES[bigram] unless BIGRAMS_FREQUENCIES[bigram].nil?
        end
        cols_pairs[bigrams_freq] = cols_ids
      end
      p cols_pairs.sort.reverse.to_h.inspect
    end
        # perms.each do |perm|
        #   perm_text = []
        #   perm.each do |i|
        #     perm_text << m.column(i).to_a.join
        #   end
        #   # file.write("Dimensions: #{dims} Permutation: #{perm} Text: #{perm_text.join}")
        # end
    # }
  end

  def self.decipher(cipher_text)
    size = cipher_text.size
    i = 2

    poss_sizes = []
    while i < size
      poss_sizes.append [i, size / i] if (size % i).zero?
      i += 1
    end

    find_best(cipher_text, poss_sizes)
  end
end

TranspositionCipher.decipher gets.delete " \n\t"
