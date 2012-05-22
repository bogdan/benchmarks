require "diffbench"

# After patch
/\A\/account\/((?-mix:twitter|github))\/callback(?:\.([^\/.?]+))?\Z/

$:.unshift("./lib")

require "journey"

routes    = Journey::Routes.new
router    = Journey::Router.new(routes, {})
formatter = Journey::Formatter.new(routes)

def add_routes router, paths
  paths.each do |path|
    path  = Journey::Path::Pattern.new path
    router.routes.add_route nil, path, {}, {}, {}
  end
end
add_routes router, [
  Journey::Router::Strexp.new("/foo/:id(.:format)", { :id => /\d+/ }, ['/', '.', '?'], false)
]


DiffBench.bm do
  report "generate" do
    100.times do
      formatter.generate(:path_info, nil, { :id => '10' }, { })
    end
  end
end

