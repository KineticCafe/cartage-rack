# -*- encoding: utf-8 -*-
# stub: cartage-rack 2.3 ruby lib

Gem::Specification.new do |s|
  s.name = "cartage-rack".freeze
  s.version = "2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/KineticCafe/cartage-rack/" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Austin Ziegler".freeze, "Kinetic Commerce".freeze]
  s.date = "2022-12-16"
  s.description = "This release is the *last* version of cartage-rack. It will be replaced with\na different tool in the future, but this release will allow installation in\nmodern Ruby versions.\n\ncartage-rack is a plug-in for\n{cartage}[https://github.com/KineticCafe/cartage] to provide a Rack\napplication that reports on release metadata.\n\nCartage provides a repeatable means to create a package for a Rails\napplication that can be used in deployment with a configuration tool like\nAnsible, Chef, Puppet, or Salt. The package is created with its dependencies\nbundled in +vendor/bundle+, so it can be deployed in environments with strict\naccess control rules and without requiring development tool access.".freeze
  s.email = ["aziegler@kineticcommerce.com".freeze, "dev@kineticcommerce.com".freeze]
  s.extra_rdoc_files = ["Contributing.md".freeze, "History.md".freeze, "Licence.md".freeze, "Manifest.txt".freeze, "README.rdoc".freeze]
  s.files = ["Contributing.md".freeze, "History.md".freeze, "Licence.md".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "Rakefile".freeze, "lib/cartage/rack.rb".freeze, "lib/cartage/rack/metadata.rb".freeze, "lib/cartage/rack/simple.rb".freeze, "test/minitest_helper.rb".freeze, "test/test_cartage_rack.rb".freeze, "test/test_cartage_rack_metadata.rb".freeze, "test/test_cartage_rack_simple.rb".freeze]
  s.homepage = "https://github.com/KineticCafe/cartage-rack/".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.required_ruby_version = Gem::Requirement.new([">= 2.7".freeze, "< 4".freeze])
  s.rubygems_version = "3.3.26".freeze
  s.summary = "This release is the *last* version of cartage-rack".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<appraisal>.freeze, ["~> 2.4"])
    s.add_development_dependency(%q<hoe-doofus>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<hoe-gemspec2>.freeze, ["~> 1.1"])
    s.add_development_dependency(%q<hoe-git2>.freeze, ["~> 1.7"])
    s.add_development_dependency(%q<hoe-rubygems>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.16"])
    s.add_development_dependency(%q<minitest-autotest>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<minitest-bisect>.freeze, ["~> 1.2"])
    s.add_development_dependency(%q<minitest-focus>.freeze, ["~> 1.1"])
    s.add_development_dependency(%q<minitest-hooks>.freeze, ["~> 1.4"])
    s.add_development_dependency(%q<minitest-moar>.freeze, ["~> 0.0"])
    s.add_development_dependency(%q<minitest-pretty_diff>.freeze, ["~> 0.1"])
    s.add_development_dependency(%q<rack-test>.freeze, ["~> 2.0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 10.0", "< 14"])
    s.add_development_dependency(%q<rdoc>.freeze, ["~> 6.4"])
    s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.7"])
    s.add_development_dependency(%q<standard>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<timecop>.freeze, ["~> 0.8"])
    s.add_development_dependency(%q<hoe>.freeze, ["~> 3.26"])
  else
    s.add_dependency(%q<appraisal>.freeze, ["~> 2.4"])
    s.add_dependency(%q<hoe-doofus>.freeze, ["~> 1.0"])
    s.add_dependency(%q<hoe-gemspec2>.freeze, ["~> 1.1"])
    s.add_dependency(%q<hoe-git2>.freeze, ["~> 1.7"])
    s.add_dependency(%q<hoe-rubygems>.freeze, ["~> 1.0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.16"])
    s.add_dependency(%q<minitest-autotest>.freeze, ["~> 1.0"])
    s.add_dependency(%q<minitest-bisect>.freeze, ["~> 1.2"])
    s.add_dependency(%q<minitest-focus>.freeze, ["~> 1.1"])
    s.add_dependency(%q<minitest-hooks>.freeze, ["~> 1.4"])
    s.add_dependency(%q<minitest-moar>.freeze, ["~> 0.0"])
    s.add_dependency(%q<minitest-pretty_diff>.freeze, ["~> 0.1"])
    s.add_dependency(%q<rack-test>.freeze, ["~> 2.0"])
    s.add_dependency(%q<rake>.freeze, [">= 10.0", "< 14"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 6.4"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
    s.add_dependency(%q<standard>.freeze, ["~> 1.0"])
    s.add_dependency(%q<timecop>.freeze, ["~> 0.8"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.26"])
  end
end
