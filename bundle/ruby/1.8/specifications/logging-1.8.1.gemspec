# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{logging}
  s.version = "1.8.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Pease"]
  s.date = %q{2013-01-02}
  s.description = %q{Logging is a flexible logging library for use in Ruby programs based on the
design of Java's log4j library. It features a hierarchical logging system,
custom level names, multiple output destinations per log event, custom
formatting, and more.}
  s.email = %q{tim.pease@gmail.com}
  s.files = ["test/appenders/test_buffered_io.rb", "test/appenders/test_console.rb", "test/appenders/test_email.rb", "test/appenders/test_file.rb", "test/appenders/test_growl.rb", "test/appenders/test_io.rb", "test/appenders/test_periodic_flushing.rb", "test/appenders/test_rolling_file.rb", "test/appenders/test_string_io.rb", "test/appenders/test_syslog.rb", "test/config/test_configurator.rb", "test/config/test_yaml_configurator.rb", "test/layouts/test_basic.rb", "test/layouts/test_color_pattern.rb", "test/layouts/test_json.rb", "test/layouts/test_pattern.rb", "test/layouts/test_yaml.rb", "test/test_appender.rb", "test/test_color_scheme.rb", "test/test_consolidate.rb", "test/test_layout.rb", "test/test_log_event.rb", "test/test_logger.rb", "test/test_logging.rb", "test/test_mapped_diagnostic_context.rb", "test/test_nested_diagnostic_context.rb", "test/test_proxy.rb", "test/test_repository.rb", "test/test_root_logger.rb", "test/test_stats.rb", "test/test_utils.rb"]
  s.homepage = %q{http://rubygems.org/gems/logging}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{logging}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A flexible and extendable logging library for Ruby}
  s.test_files = ["test/appenders/test_buffered_io.rb", "test/appenders/test_console.rb", "test/appenders/test_email.rb", "test/appenders/test_file.rb", "test/appenders/test_growl.rb", "test/appenders/test_io.rb", "test/appenders/test_periodic_flushing.rb", "test/appenders/test_rolling_file.rb", "test/appenders/test_string_io.rb", "test/appenders/test_syslog.rb", "test/config/test_configurator.rb", "test/config/test_yaml_configurator.rb", "test/layouts/test_basic.rb", "test/layouts/test_color_pattern.rb", "test/layouts/test_json.rb", "test/layouts/test_pattern.rb", "test/layouts/test_yaml.rb", "test/test_appender.rb", "test/test_color_scheme.rb", "test/test_consolidate.rb", "test/test_layout.rb", "test/test_log_event.rb", "test/test_logger.rb", "test/test_logging.rb", "test/test_mapped_diagnostic_context.rb", "test/test_nested_diagnostic_context.rb", "test/test_proxy.rb", "test/test_repository.rb", "test/test_root_logger.rb", "test/test_stats.rb", "test/test_utils.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<little-plugger>, [">= 1.1.3"])
      s.add_runtime_dependency(%q<multi_json>, [">= 1.3.6"])
      s.add_development_dependency(%q<flexmock>, ["~> 1.0"])
      s.add_development_dependency(%q<bones-git>, [">= 1.3.0"])
      s.add_development_dependency(%q<bones>, [">= 3.8.0"])
    else
      s.add_dependency(%q<little-plugger>, [">= 1.1.3"])
      s.add_dependency(%q<multi_json>, [">= 1.3.6"])
      s.add_dependency(%q<flexmock>, ["~> 1.0"])
      s.add_dependency(%q<bones-git>, [">= 1.3.0"])
      s.add_dependency(%q<bones>, [">= 3.8.0"])
    end
  else
    s.add_dependency(%q<little-plugger>, [">= 1.1.3"])
    s.add_dependency(%q<multi_json>, [">= 1.3.6"])
    s.add_dependency(%q<flexmock>, ["~> 1.0"])
    s.add_dependency(%q<bones-git>, [">= 1.3.0"])
    s.add_dependency(%q<bones>, [">= 3.8.0"])
  end
end
