
require "diffbench"
require "benchmark/ips"
require 'perftools'
require "bundler"
Bundler.require
$:.unshift "../railties/lib"
$:.unshift "../activesupport/lib"
$:.unshift "../activemodel/lib"
$:.unshift "../activerecord/lib"
require "active_record"
require 'rails'

#require 'perftools'


ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Base.configurations = true

#ActiveRecord::Base.logger = TEST_LOGGER




ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define(:version => 1) do

  create_table :groups do |t|
    t.string :name
    t.float :rating
    t.timestamps
  end

  class ::Group < ActiveRecord::Base
    has_many :entries
  end
end

Group.transaction do
  10000.times do
    Group.connection.execute("insert into groups (name, rating) values (?, ?)", a: "hello"+rand(10000).to_s, b: rand(10) )
  end
end

puts "Groups:"  + Group.count.to_s


GC.disable
Benchmark.ips do |z|
  #PerfTools::CpuProfiler.start("/tmp/add_numbers_profile#{ENV['NUM']}") do
    [
      10,
      100,
      1000,
      10000
    ].each do |amount|
      [
        [:name],
        #[:id, :name],
        #[:id, :name, :rating]
      ].each do |columns|
        z.report "pluck #{columns.size} columns and #{amount} records" do
          #(10_000 / amount).times do
            Group.limit(amount).pluck(*columns)
          #end
          #GC.start
        end
      end
    #end
  end
end




=begin

#
# After Patch
#

Groups:10000
Calculating -------------------------------------
pluck 1 columns and 10 records
                           686 i/100ms
pluck 1 columns and 100 records
                           328 i/100ms
pluck 1 columns and 1000 records
                            52 i/100ms
pluck 1 columns and 10000 records
                             4 i/100ms
-------------------------------------------------
pluck 1 columns and 10 records
                         6814.3 (±3.6%) i/s -      34300 in   5.040195s
pluck 1 columns and 100 records
                         2596.3 (±14.0%) i/s -      12792 in   5.098327s
pluck 1 columns and 1000 records
                          305.3 (±20.3%) i/s -       1456 in   5.037526s
pluck 1 columns and 10000 records
                           24.9 (±36.1%) i/s -        108 in   5.143262s

#
# Before Patch
#

Calculating -------------------------------------
pluck 1 columns and 10 records
                           654 i/100ms
pluck 1 columns and 100 records
                           258 i/100ms
pluck 1 columns and 1000 records
                            36 i/100ms
pluck 1 columns and 10000 records
                             3 i/100ms
-------------------------------------------------
pluck 1 columns and 10 records
                         6297.5 (±2.2%) i/s -      32046 in   5.091279s
pluck 1 columns and 100 records
                         1964.6 (±23.6%) i/s -       9030 in   5.090748s
pluck 1 columns and 1000 records
                          161.1 (±44.7%) i/s -        684 in   5.917276s
pluck 1 columns and 10000 records
                            7.9 (±38.1%) i/s -         36 in   5.439820s
=end
