class Hash
  def +(add)
    temp = {}
    add.each  { |k, v| temp[k] = v }
    self.each { |k, v| temp[k] = v + add[k] unless add[k].nil? }
    temp
  end
end

tests = []
line = 0

until $stdin.eof?
  # get rid of the 1kb file stats
  11.times do
    $stdin.readline
  end

  # read the test profile and average the 10 runs
  test = eval($stdin.readline)
  stats = {}
  10.times do
    stats = stats + eval($stdin.readline)
  end
  stats.each do |key, value|
    stats[key] /= 10.0
  end

  # append stats to test profile
  test[:stats] = stats
  tests << test
end

puts tests
