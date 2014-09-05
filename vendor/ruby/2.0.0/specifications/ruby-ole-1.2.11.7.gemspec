# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ruby-ole"
  s.version = "1.2.11.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Charles Lowe"]
  s.date = "2013-06-23"
  s.description = "A library for easy read/write access to OLE compound documents for Ruby."
  s.email = "aquasync@gmail.com"
  s.executables = ["oletool"]
  s.extra_rdoc_files = ["README", "ChangeLog"]
  s.files = ["bin/oletool", "README", "ChangeLog"]
  s.homepage = "http://code.google.com/p/ruby-ole"
  s.rdoc_options = ["--main", "README", "--title", "ruby-ole documentation", "--tab-width", "2"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "ruby-ole"
  s.rubygems_version = "2.0.3"
  s.summary = "Ruby OLE library."
end
