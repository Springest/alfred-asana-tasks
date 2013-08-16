# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{little-plugger}
  s.version = "1.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Pease"]
  s.date = %q{2011-11-17 00:00:00.000000000Z}
  s.description = %q{LittlePlugger is a module that provides Gem based plugin management.
By extending your own class or module with LittlePlugger you can easily
manage the loading and initializing of plugins provided by other gems.}
  s.email = %q{tim.pease@gmail.com}
  s.homepage = %q{http://gemcutter.org/gems/little-plugger}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{little-plugger}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{LittlePlugger is a module that provides Gem based plugin management.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 2.7.0"])
    else
      s.add_dependency(%q<rspec>, [">= 2.7.0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 2.7.0"])
  end
end
