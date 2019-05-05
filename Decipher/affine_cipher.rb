require '../Decipher/helper_functions'

class AffineCipher
  # Deciphers affine cipher using the brute force method.
  # For English alphabet only 12*26 = 312 combinations of A and B.
  # @param [Integer] x
  # @param [String] cipher_text
  def self.decipher(cipher_text)
    File.open('affine_cipher', 'w') { |file|
      alphabet_size = HelperFunctions::ALPHABET.size

      # Find all possible A's for alphabet length given in x
      coprimes = HelperFunctions.find_coprimes alphabet_size

      # Find A' to A in mod x
      a_pairs = []
      coprimes.each { |a|
        _a = 1
        while (_a * a) % alphabet_size != 1
          _a += 1
        end
        a_pairs << [a, _a]
      }

      #Transform letters from text to numbers
      text_ids = []
      cipher_text.each_char { |c| text_ids << HelperFunctions::ALPHABET.index(c) }

      #Brute force
      solutions = Hash.new(0)
      a_pairs.each { |a, _a|
        (1..alphabet_size).each { |b|
          _text = HelperFunctions.affine_inverse HelperFunctions::ALPHABET, text_ids, _a, b
          _text_freq = HelperFunctions.frequency_analysis(_text)
          freq_diff = 0
          _text_freq.each_key { |c|
            freq_diff += (HelperFunctions::LETTER_FREQUENCIES[c] - _text_freq[c]).abs
          }
          solutions[freq_diff] = [a, b, _text]
        }
      }

      solutions = solutions.sort

      solutions.each { |key, data|
        file.write("A: #{data[0]} B: #{data[1]} Text: #{data[2]} Frequency difference: #{key}\n")
      }
    }
  end
end

AffineCipher.decipher STDIN.gets.delete " \n\t"