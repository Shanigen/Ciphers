require "../Decipher/helper_functions"

class VignereCipher
  ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".freeze
  LETTER_FREQUENCIES = {a: 8.167, b: 1.492, c: 2.782, d: 4.253, e: 12.702, f: 2.228,
                        g: 2.015, h: 6.094, i: 6.966, j: 0.153, k: 0.772, l: 4.025,
                        m: 2.406, n: 6.749, o: 7.507, p: 1.929, q: 0.095, r: 5.987,
                        s: 6.327, t: 9.056, u: 2.758, v: 0.978, w: 2.360, x: 0.150,
                        y: 1.974, z: 0.074,}.freeze
  # Unnormalized IOC, normalization is performed like this: ioc_norm = ioc_unnorm/alphabet_len
  IOC = 1.73

  # Decryption of Vignere cipher using substractions of letters.
  def self.vignere_decryption(alphabet_len, key_ids, text_ids)
    op_ids = []

    i = 0
    text_ids.each do |id|
      tmp = id - key_ids[i % key_ids.size]
      tmp = tmp >= 0 ? tmp : tmp + alphabet_len
      op_ids << tmp
      i += 1
    end

    op_ids
  end

  def self.decipher(cipher_text)
    len = cipher_text.size
    delta_iocs = Hash.new(0)

    (1..20).each do |key_len|
      delta_ioc = 0
      (0...key_len).each do |col|
        id = col
        col_letters = ""
        while id < len
          col_letters << cipher_text[id]
          id += key_len
        end
        delta_ioc += HelperFunctions.ioc col_letters
      end
      delta_iocs[key_len] = (delta_ioc / key_len).round 2, half: :down
    end

    min_diff = Float::INFINITY
    best_key_len = 0
    delta_iocs.each do |key_len, delta_ioc|
      diff = IOC - delta_ioc
      if diff.abs < min_diff
        min_diff = diff
        best_key_len = key_len
      end
    end

    columns = []
    (0...best_key_len).each do |col|
      id = col
      col_letters = ""
      while id < len
        col_letters << cipher_text[id]
        id += best_key_len
      end
      columns << col_letters
    end

    key = ""
    columns.each do |col_text|
      text_ids = []
      best_correlation = 0
      best_b = -1

      col_text.each_char { |c| text_ids << ALPHABET.index(c) }

      (0...ALPHABET.size).each do |b|
        frequencies = HelperFunctions.frequency_analysis HelperFunctions.affine_inverse ALPHABET, text_ids, 1, b
        correlation = 0
        frequencies.each { |c, n| correlation += LETTER_FREQUENCIES[c.downcase.to_sym] / 100 * n / 100 }
        if correlation > best_correlation
          best_correlation = correlation
          best_b = b
        end
      end

      key << ALPHABET[best_b]
    end

    puts "Key: #{key}"

    key_ids = []
    text_ids = []
    key.each_char { |c| key_ids << ALPHABET.index(c) }
    cipher_text.each_char { |c| text_ids << ALPHABET.index(c) }

    op_ids = VignereCipher.vignere_decryption ALPHABET.size, key_ids, text_ids

    op_text = ""
    op_ids.each { |id| op_text << ALPHABET[id] }
    puts "Message: #{op_text}"
  end
end

VignereCipher.decipher gets.delete " \n\t"
