require "../Decipher/helper_functions"
require "matrix"

class TranspositionCipher
  # TODO: Add permutation according to the bigrams frequencies
  def self.find_best(text, sizes)
    File.open('transpose_cipher', 'w') { |file|
      sizes.each do |dims|
        file.write("#{dims}\n")
        m = Matrix.build(dims[0], dims[1]) { |row, col| text[row * dims[1] + col] }
        m.each_slice(m.column_size) {|r| file.write("#{r}\n")}
        cols = m.each_slice((dims[0]*dims[1])/m.column_size).to_a
        cols.first.zip( *cols[1..-1] ).each{|row| file.write("#{row.map{|e| e ? '%s' % e : ''}.join("")}") }
        file.write("\n")
        perms = (0...dims[0]).to_a.permutation(2).to_a

        rows_pairs = {}
        perms.each do |row_ids|
          bigrams_freq = 0
          (0...dims[1]).each do |j|
            bigram = [m.element(row_ids[0], j), m.element(row_ids[1], j)].join.downcase.to_sym
            bigrams_freq += HelperFunctions::BIGRAMS_FREQUENCIES[bigram] unless HelperFunctions::BIGRAMS_FREQUENCIES[bigram].nil?
          end
          rows_pairs[bigrams_freq] = [row_ids[0] + 1, row_ids[1] + 1]
        end
        file.write("#{rows_pairs.sort.reverse.to_h.inspect}\n")
      end
    }
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

TranspositionCipher.decipher STDIN.gets.delete " \n\t"
