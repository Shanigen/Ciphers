require '../Decipher/helper_functions'

class VignereCipher
  # Decryption of Vignere cipher using substractions of letters.
  def self.vignere_decryption(alphabet_len, key_ids, text_ids)
    op_ids = []

    i = 0
    text_ids.each { |id|
      tmp = id - key_ids[i % key_ids.size]
      tmp = tmp >= 0 ? tmp : tmp + alphabet_len
      op_ids << tmp
      i += 1
    }

    return op_ids
  end

  def self.decipher(cipher_text)
    len = cipher_text.size
    delta_iocs = Hash.new(0)

    (1..20).each { |key_len|
      delta_ioc = 0
      (0...key_len).each { |col|
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

    min_diff = Float::INFINITY
    best_key_len = 0
    delta_iocs.each { |key_len, delta_ioc|
      diff = HelperFunctions::IOC - delta_ioc
      if diff.abs < min_diff
        min_diff = diff
        best_key_len = key_len
      end
    }

    columns = []
    (0...best_key_len).each { |col|
      id = col
      col_letters = ''
      while id < len
        col_letters << cipher_text[id]
        id += best_key_len
      end
      columns << col_letters
    }

    key = ''
    columns.each { |col_text|
      text_ids = []
      best_correlation = 0
      best_b = -1

      col_text.each_char { |c| text_ids << HelperFunctions::ALPHABET.index(c) }

      (0...HelperFunctions::ALPHABET.size).each { |b|
        frequencies = HelperFunctions.frequency_analysis HelperFunctions.affine_inverse HelperFunctions::ALPHABET, text_ids, 1, b
        correlation = 0
        frequencies.each { |c, n| correlation += HelperFunctions::LETTER_FREQUENCIES[c.downcase.to_sym] / 100 * n / 100 }
        if correlation > best_correlation
          best_correlation = correlation
          best_b = b
        end
      }

      key << HelperFunctions::ALPHABET[best_b]
    }

    puts "Key: #{key}"

    key_ids = []
    text_ids = []
    key.each_char { |c| key_ids << HelperFunctions::ALPHABET.index(c) }
    cipher_text.each_char { |c| text_ids << HelperFunctions::ALPHABET.index(c) }

    op_ids = VignereCipher.vignere_decryption HelperFunctions::ALPHABET.size, key_ids, text_ids

    op_text = ''
    op_ids.each { |id| op_text << HelperFunctions::ALPHABET[id] }
    puts "Message: #{op_text}"
  end
end

VignereCipher.decipher STDIN.gets.delete " \n\t"