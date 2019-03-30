require "../Decipher/helper_functions"

class AffineCipher
  ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".freeze
  LETTER_FREQUENCIES = {a: 8.167, b: 1.492, c: 2.782, d: 4.253, e: 12.702, f: 2.228,
                        g: 2.015, h: 6.094, i: 6.966, j: 0.153, k: 0.772, l: 4.025,
                        m: 2.406, n: 6.749, o: 7.507, p: 1.929, q: 0.095, r: 5.987,
                        s: 6.327, t: 9.056, u: 2.758, v: 0.978, w: 2.360, x: 0.150,
                        y: 1.974, z: 0.074,}.freeze
  # Unnormalized IOC, normalization is performed like this: ioc_norm = ioc_unnorm/alphabet_len
  IOC = 1.73

  # Deciphers affine cipher using the brute force method.
  # For English alphabet only 12*26 = 312 combinations of A and B.
  # @param [Integer] x
  # @param [String] cipher_text
  def self.decipher(cipher_text)
    p cipher_text
    File.open("affine_cipher", "w") { |file|
      alphabet_size = ALPHABET.size

      # Find all possible A's for alphabet length given in x
      coprimes = HelperFunctions.find_coprimes alphabet_size

      # Find A' to A in mod x
      a_pairs = []
      coprimes.each do |a|
        a2 = 1
        a2 += 1 while (a2 * a) % alphabet_size != 1
        a_pairs << [a, a2]
      end

      # Transform letters from text to numbers
      text_ids = []
      cipher_text.each_char { |c| text_ids << ALPHABET.index(c) }

      # Brute force
      solutions = Hash.new(0)
      a_pairs.each do |a, a2|
        (1..alphabet_size).each do |b|
          text = HelperFunctions.affine_inverse ALPHABET, text_ids, a2, b
          text_freq = HelperFunctions.frequency_analysis(text)
          freq_diff = 0
          text_freq.each_key do |c|
            freq_diff += (LETTER_FREQUENCIES[c] - text_freq[c]).abs
          end
          solutions[freq_diff] = [a, b, text]
        end
      end

      solutions = solutions.sort

      solutions.each do |key, data|
        file.write("A: #{data[0]} B: #{data[1]} Text: #{data[2]} Frequency difference: #{key}\n")
      end
    }
  end
end

AffineCipher.decipher gets.delete " \n\t"
