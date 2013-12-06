Gem::Specification.new do |s|
  s.name          = 'chef-handler-portal-communicator'
  s.version       = '0.1.0'
  s.platform      = Gem::Platform::RUBY
  s.author        = "Warren Bain"
  s.email         = "ninefolddev@ninefold.com"
  s.summary       = %q(Chef report handler for communicating run status to a configured endpoint)
  s.description   = %q(Chef report handler for communicating run status to a configured endpoint)
  s.homepage      = "https://github.com/ninefold/chef-handler-portal-communicator"

  s.require_paths = %w(lib)
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
end

