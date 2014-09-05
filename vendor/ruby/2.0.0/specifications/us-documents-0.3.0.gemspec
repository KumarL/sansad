# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "us-documents"
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eric Mill"]
  s.date = "2013-05-30"
  s.description = "Process legal documents into integration-friendly HTML."
  s.email = "eric@sunlightfoundation.com"
  s.executables = ["us-documents"]
  s.files = ["bin/us-documents"]
  s.homepage = "https://github.com/unitedstates/documents"
  s.licenses = ["unlicense"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "Process legal documents into integration-friendly HTML."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 0"])
  end
end
