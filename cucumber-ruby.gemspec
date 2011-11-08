Gem::Specification.new do |s|
  s.name        = 'cucumber-ruby'
  s.version     = '1.99.1'
  s.authors     = ["Mike Sassak"]
  s.description = "Pure-ruby Cucumber 2.x"
  s.summary     = "cucumber #{s.version}"
  s.email       = "msassak@gmail.com"
  s.homepage    = "https://github.com/msassak/cucumber-ruby"

  s.add_dependency 'kerplutz', '>= 0.1.2'
  s.add_dependency 'gherkin'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'timecop'

  s.rubygems_version   = "1.3.7"
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.extra_rdoc_files = ["LICENSE", "README.md"]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"
end
