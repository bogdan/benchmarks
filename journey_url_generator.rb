require "diffbench"

$:.unshift("./lib")

require "journey"
require 'perftools'

GC.disable
routes    = Journey::Routes.new
router    = Journey::Router.new(routes, {})
formatter = Journey::Formatter.new(routes)

def add_routes router, paths, name
  paths.each do |path|
    path  = Journey::Path::Pattern.new path
    router.routes.add_route nil, path, {}, {}, name
  end
end
add_routes router, [
  Journey::Router::Strexp.new("/foo/:id(.:format)", { :id => /\d+/ }, ['/', '.', '?'], false)
], "r1"
add_routes router, [
  Journey::Router::Strexp.new("/pages/*page(.:format)", {}, ['/', '.', '?'], false)
], "r2"

#PerfTools::CpuProfiler.start("/tmp/formatter") do
  #100000.times do
    #formatter.generate(:path_info, "r1", { :id => '10' }, { })
  #end
#end

DiffBench.bm do
  report "generate" do
    1000.times do
      formatter.generate(:path_info, nil, { :id => '10' }, { })
    end
  end
  report "generate with globbing" do
    1000.times do
      formatter.generate(:path_info, nil, { :page => 'faq' }, { })
    end
  end
end

GC.enable
