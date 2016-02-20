require 'csv'

ff = 'gbsmall.txt'
ff2 = 'gbsmall2.txt'
dat = File.read(ff)
csv = CSV.new(dat, :headers => false, :converters => :all)
ids = csv.map(&:first)
rows = ids.map { |e| ['"SET"', "\"%s\"" % e, '"*"'].join(' ') }
File.open(ff2, "w+") do |f|
  f.puts(rows)
end
