require 'rake'
require 'rspec/core/rake_task'

desc "Run all specs"
RSpec::Core::RakeTask.new(:test)

task :default => :test

######################################################

require 'rake'
require 'rake/clean'
require 'rubygems'
require 'rubygems/package_task'
require 'fileutils'

Gem::PackageTask.new(eval File.read('pony.gemspec')) do |p|
	p.need_tar = true if RUBY_PLATFORM !~ /mswin/
end

task :install => [ :package ] do
	sh %{sudo gem install pkg/#{name}-#{version}.gem}
end

task :uninstall => [ :clean ] do
	sh %{sudo gem uninstall #{name}}
end

CLEAN.include [ 'pkg', '*.gem', '.config' ]
