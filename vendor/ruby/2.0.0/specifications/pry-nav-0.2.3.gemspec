# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "pry-nav"
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gopal Patel"]
  s.date = "2012-12-26"
  s.description = "Turn Pry into a primitive debugger. Adds 'step' and 'next' commands to control execution."
  s.email = "nixme@stillhope.com"
  s.homepage = "https://github.com/nixme/pry-nav"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubygems_version = "2.0.3"
  s.summary = "Simple execution navigation for Pry."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<pry>, ["~> 0.9.10"])
      s.add_development_dependency(%q<pry-remote>, ["~> 0.1.6"])
    else
      s.add_dependency(%q<pry>, ["~> 0.9.10"])
      s.add_dependency(%q<pry-remote>, ["~> 0.1.6"])
    end
  else
    s.add_dependency(%q<pry>, ["~> 0.9.10"])
    s.add_dependency(%q<pry-remote>, ["~> 0.1.6"])
  end
end
