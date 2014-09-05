# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "timecop"
  s.version = "0.7.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Travis Jeffery", "John Trupiano"]
  s.date = "2013-12-30"
  s.description = "A gem providing \"time travel\" and \"time freezing\" capabilities, making it dead simple to test time-dependent code.  It provides a unified method to mock Time.now, Date.today, and DateTime.now in a single call."
  s.email = "travisjeffery@gmail.com"
  s.extra_rdoc_files = ["LICENSE", "README.markdown"]
  s.files = ["LICENSE", "README.markdown"]
  s.homepage = "https://github.com/travisjeffery/timecop"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.rubyforge_project = "timecop"
  s.rubygems_version = "2.0.3"
  s.summary = "A gem providing \"time travel\" and \"time freezing\" capabilities, making it dead simple to test time-dependent code.  It provides a unified method to mock Time.now, Date.today, and DateTime.now in a single call."
end
