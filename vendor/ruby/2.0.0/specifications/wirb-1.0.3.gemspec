# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "wirb"
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jan Lelis"]
  s.date = "2014-01-13"
  s.description = "Wavy IRB: Colorizes irb results. It originated from Wirble, but only provides result highlighting. Just call Wirb.start and enjoy the colors in your IRB ;). You can use it with your favorite colorizer engine. See README.rdoc for more details."
  s.email = "mail@janlelis.de"
  s.extra_rdoc_files = ["README.rdoc", "COPYING.txt"]
  s.files = ["README.rdoc", "COPYING.txt"]
  s.homepage = "https://github.com/janlelis/wirb"
  s.licenses = ["MIT"]
  s.post_install_message = "       \u{250c}\u{2500}\u{2500} info \u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2510}\n J-_-L \u{2502} https://github.com/janlelis/wirb \u{2502}\n       \u{251c}\u{2500}\u{2500} usage \u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2524}\n       \u{2502} require 'wirb'                   \u{2502}\n       \u{2502} Wirb.start                       \u{2502}\n       \u{2514}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2518}"
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubygems_version = "2.0.3"
  s.summary = "Wavy IRB: Colorizes irb results."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<paint>, ["~> 0.8"])
      s.add_development_dependency(%q<rspec>, ["~> 2.14"])
      s.add_development_dependency(%q<rake>, ["~> 10.1"])
      s.add_development_dependency(%q<zucker>, ["~> 13"])
    else
      s.add_dependency(%q<paint>, ["~> 0.8"])
      s.add_dependency(%q<rspec>, ["~> 2.14"])
      s.add_dependency(%q<rake>, ["~> 10.1"])
      s.add_dependency(%q<zucker>, ["~> 13"])
    end
  else
    s.add_dependency(%q<paint>, ["~> 0.8"])
    s.add_dependency(%q<rspec>, ["~> 2.14"])
    s.add_dependency(%q<rake>, ["~> 10.1"])
    s.add_dependency(%q<zucker>, ["~> 13"])
  end
end