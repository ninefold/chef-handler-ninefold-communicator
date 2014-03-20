Gem::Specification.new do |s|
  s.name          = 'chef-handler-ninefold-communicator'
  s.version       = '0.2.1'
  s.platform      = Gem::Platform::RUBY
  s.author        = "Warren Bain"
  s.email         = "ninefolddev@ninefold.com"
  s.summary       = %q(Chef report handler for communicating run status in a structured way)
  s.description   = %q(Chef report handler for communicating run status to a structured way)
  s.homepage      = "https://github.com/ninefold/chef-handler-ninefold-communicator"

  s.require_paths = %w(lib)
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
end

