# gist:7657655
require "benchmark"
amount = 1000000
h = {a: 1, b: 2, c: 3, d: 4}

def run(k, v)
  # some operation here
  nil
end
Benchmark.bmbm do |x|
  x.report do
    amount.times do
      h.each {|k,v| run(k,v)}
    end
  end
  x.report do
    amount.times do
      h.each_key {|k| run(k, h[k])}
    end
  end
end

#Rehearsal ------------------------------------
#   0.660000   0.000000   0.660000 (  0.664009)
#   0.500000   0.000000   0.500000 (  0.495349)
#--------------------------- total: 1.160000sec
#
#       user     system      total        real
#   0.660000   0.000000   0.660000 (  0.664160)
#   0.500000   0.000000   0.500000 (  0.495522)
