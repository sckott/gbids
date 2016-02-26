require 'csv'

# input file
ff = 'gbsmall.txt'

# read file
dat = File.read(ff)
csv = CSV.new(dat, :headers => false, :converters => :all).to_a

# make acc2gi file
file_acc = 'accdat.txt'

rows = csv.collect { |row|
	['"SET"', "\"%s\"" % row[0], "\"%s\"" % row[2]].join(' ')
}

File.open(file_acc, "w+") do |f|
  f.puts(rows)
end

# make gi2acc file
file_gi = 'gidat.txt'

rows = csv.collect { |row|
	['"SET"', "\"%s\"" % row[2], "\"%s\"" % row[0]].join(' ')
}

File.open(file_gi, "w+") do |f|
  f.puts(rows)
end
