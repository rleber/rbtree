# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rbtree}
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["OZAWA Takuma", "Richard LeBer"]
  s.date = %q{2010-05-04}
  s.description = %q{RBTree is a sorted associative collection that is implemented with a Red-Black Tree. The elements of RBTree are ordered and its interface is the almost same as Hash, so you can consider RBTree to be simply a sorted Hash.}
  s.email = ["rleber@mindspring.com"]
  s.extra_rdoc_files = ["ChangeLog", "MANIFEST"]
  s.files = [
    "ChangeLog",
    "LICENSE",
    "MANIFEST",
    "README",
    "depend",
    "dict.c",
    "dict.h",
    "extconf.rb",
    "rbtree.c",
    "test.rb"
  ]
  s.homepage = %q{http://github.com/rleber/rbtree}
  s.rdoc_options = ["--main", "README"]
  s.rubyforge_project = %q{rbtree}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Associative collection using Red-Black trees.}
  s.test_files = ["test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3
  end
end
