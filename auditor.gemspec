# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'auditor/version'
 
Gem::Specification.new do |s|
  s.name        = "auditor"
  s.version     = Auditor::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jeff Kunkle", "Matt Wizeman"]
  s.homepage    = "http://github.com/nearinfinity/auditor"
  s.summary     = "Rails 3 plugin for auditing access to your ActiveRecord model objects"
  s.description = "Auditor allows you to declaratively specify what CRUD operations should be audited and save the audit data to the database."
  s.license     = "MIT"
 
  s.required_rubygems_version = ">= 1.3.6"
 
  s.add_development_dependency "rspec"
 
  s.files        = Dir.glob("{lib}/**/*") + %w(LICENSE README.rdoc)
  s.test_files   = Dir.glob("{spec}/**/*")
  s.require_path = 'lib'
end