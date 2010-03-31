class Array

  # This turns a flat array into an array of n (specified number) arrays.
  #
  #     [1, 4, 2, 5, 3, 6].chunk 2
  #     => [[1, 4, 2, [5, 3, 6]]
  #
  # @param [Integer] chunk_count the number of arrays the receiver must be split into
  # @return [Array(Array)]
  def chunk(chunk_count)
    chunks = (0...chunk_count).collect { [] }
    (0...length).each { |i| chunks[i % chunk_count][i / chunk_count] = self[i] }
    chunks
  end
  alias / chunk

  # This turns a flat array into an array of arrays of the specified size.
  #
  #     [1, 4, 2, 5, 3, 6].explode_in_pairs_of 2
  #     => [[1, 4], [2, 5], [3, 6]]
  #
  # @param [Integer] num the size of the arrays
  # @return [Array(Array)]
  def explode_in_tuple_of num
    raise ArgumentError, "Must provide an Integer" if not num.is_a? Integer
    raise ArgumentError, "Must provide a number so that the receiver is a multiple (modulo == 0)" if (self.size % num) != 0
    raise ArgumentError, "Must provide a number not superior to half the size of the receiver" if (self.size / num) == 1
    chunk(self.size / num)
  end

  # Convenience method to get pairs of nodes, for instance.
  #
  # @return [Array(Array)] a flat array of array of size 2
  def explode_in_pairs
    explode_in_tuple_of 2
  end
end

a = [1, 4, 2, 5, 3, 6]
