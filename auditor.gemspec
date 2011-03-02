# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "auditor/version"

Gem::Specification.new do |s|
  s.name        = "auditor"
  s.version     = Auditor::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jeff Kunkle"]
  s.homepage    = "http://github.com/nearinfinity/auditor"
  s.summary     = %q{Rails 3 plugin for auditing access to your ActiveRecord model objects}
  s.description = %q{Auditor allows you to declaratively specify what CRUD operations should be audited and save the audit data to the database.}
  s.license     = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency('rspec', '2.5.0')
  s.add_development_dependency('sqlite3-ruby', '1.3.3')
  s.add_development_dependency('activerecord', '> 3.0.0')
end
