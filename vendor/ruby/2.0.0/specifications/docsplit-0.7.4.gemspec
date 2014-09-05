# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "docsplit"
  s.version = "0.7.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeremy Ashkenas", "Samuel Clay", "Ted Han"]
  s.date = "2014-02-16"
  s.description = "    Docsplit is a command-line utility and Ruby library for splitting apart\n    documents into their component parts: searchable UTF-8 plain text, page\n    images or thumbnails in any format, PDFs, single pages, and document\n    metadata (title, author, number of pages...)\n"
  s.email = "opensource@documentcloud.org"
  s.executables = ["docsplit"]
  s.files = ["bin/docsplit"]
  s.homepage = "http://documentcloud.github.com/docsplit/"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "docsplit"
  s.rubygems_version = "2.0.3"
  s.summary = "Break Apart Documents into Images, Text, Pages and PDFs"
end
