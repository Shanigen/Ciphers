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
    len, count, frequencies = text.size, Hash.new(0), Hash.new(0)
    text.each_char {|c| count[c] += 1}
    # Perform frequency analysis
    count.each {|c, n| frequencies[c] = ((n.to_f / len) * 100).round 1, half: :down}
    frequencies.sort_by{|_,n| n}.reverse.to_h
  end

  # Calculates index of coincidence of the text.
  # @param [String] text
  def self.ioc(text)
    len, count, ioc= text.size, Hash.new(0), 0
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

  # Decryption of Vignere cipher using substractions of letters.
  def self.vignere_decryption(alphabet_len, key_ids, text_ids)
    op_ids = []

    i = 0
    text_ids.each {|id|
      tmp = id - key_ids[i % key_ids.size]
      tmp = (tmp >= 0) ? tmp : tmp + alphabet_len
      op_ids << tmp
      i += 1
    }

    return op_ids
  end
end

class UltimateDecipher
  include HelperFunctions

  ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  LETTER_FREQUENCIES = {:a => 8.167, :b => 1.492, :c => 2.782, :d => 4.253, :e => 12.702, :f => 2.228, :g => 2.015,
                        :h => 6.094, :i => 6.966, :j => 0.153, :k => 0.772, :l => 4.025, :m => 2.406, :n => 6.749,
                        :o => 7.507, :p => 1.929, :q => 0.095, :r => 5.987, :s => 6.327, :t => 9.056, :u => 2.758,
                        :v => 0.978, :w => 2.360, :x => 0.150, :y => 1.974, :z => 0.074}
  # Unnormalized IOC, normalization is performed like this: ioc_norm = ioc_unnorm/alphabet_len
  IOC = 1.73

  # Deciphers affine cipher using the brute force method.
  # For English alphabet only 12*26 = 312 combinations of A and B.
  # @param [Integer] x
  # @param [String] cipher_text
  def self.affine_decipher(cipher_text)
    File.open('affine_cipher', 'w') {|file|
      alphabet_size = ALPHABET.size

      # Find all possible A's for alphabet length given in x
      coprimes = HelperFunctions.find_coprimes alphabet_size

      # Find A' to A in mod x
      a_pairs = []
      coprimes.each {|a|
        _a = 1
        while (_a * a) % alphabet_size != 1
          _a += 1
        end
        a_pairs << [a, _a]
      }

      #Transform letters from text to numbers
      text_ids = []
      cipher_text.each_char {|c| text_ids << ALPHABET.index(c)}

      #Brute force
      a_pairs.each {|a, _a|
        (1..alphabet_size).each {|b|
          _text = HelperFunctions.affine_inverse ALPHABET, text_ids, _a, b
          file.write("A: #{a} B: #{b} Text: #{_text}\n")
        }
      }
    }
  end

  def self.vigenere_decipher(cipher_text)
    len, delta_iocs = cipher_text.size, Hash.new(0)

    (1..20).each {|key_len|
      delta_ioc = 0
      (0...key_len).each {|col|
        id = col
        col_letters = ''
        while id < len
          col_letters << cipher_text[id]
          id += key_len
        end
        delta_ioc += HelperFunctions.ioc col_letters
      }
      delta_iocs[key_len] = (delta_ioc / key_len).round 2, half: :down
    }

    min_diff, best_key_len = Float::INFINITY, 0
    delta_iocs.each {|key_len, delta_ioc|
      diff = IOC - delta_ioc
      min_diff, best_key_len = diff, key_len if diff.abs < min_diff
    }

    columns = []
    (0...best_key_len).each {|col|
      id = col
      col_letters = ''
      while id < len
        col_letters << cipher_text[id]
        id += best_key_len
      end
      columns << col_letters
    }

    key = ''
    columns.each {|col_text|
      text_ids, best_correlation, best_b = [], 0, -1

      col_text.each_char {|c| text_ids << ALPHABET.index(c)}

      (0...ALPHABET.size).each {|b|
        frequencies = HelperFunctions.frequency_analysis HelperFunctions.affine_inverse ALPHABET, text_ids, 1, b
        correlation = 0
        frequencies.each {|c, n| correlation += LETTER_FREQUENCIES[c.downcase.to_sym] / 100 * n / 100}
        best_correlation, best_b = correlation, b if correlation > best_correlation
      }

      key << ALPHABET[best_b]
    }

    puts "Key: #{key}"

    key_ids, text_ids = [], []
    key.each_char {|c| key_ids << ALPHABET.index(c)}
    cipher_text.each_char {|c| text_ids << ALPHABET.index(c)}

    op_ids = HelperFunctions.vignere_decryption ALPHABET.size, key_ids, text_ids

    op_text = ''
    op_ids.each {|id| op_text << ALPHABET[id]}
    puts "Message: #{op_text}"
  end

  def self.menu
    File.open('ciphers', 'r') {|file|
      text = file.read
      cipher_found = false

      text.each_line do |line|
        if line.include? 'Úloha'
          cipher_found = true
          puts line
        elsif cipher_ready
          puts line
          cipher = line.delete ' '
          cipher_found = false
          while true
            puts '##############################'
            puts '1) Frequency analysis 2) Index of coincidence 3) Vignere cipher'
            case c = get.chomp
            when 1
              frequency_
            when 2
            when 3
            when 4
              puts 'Not implemented'
            end
          end
        end
      end
    }
  end
end

UltimateDecipher.menu