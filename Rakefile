# -*- mode: ruby; coding: utf-8 -*-
require "rake/clean"
require "rdoc/task"
require "rubygems/package_task"

CLEAN.include("ext/Makefile", "ext/*.o", "ext/mkmf.log")
CLOBBER.include("ext/*.so")

desc "Compiles the library"
task :compile do
  cd "ext" do
    ruby "extconf.rb"
    sh "make"
  end
end

task :test => :compile do
  cd "test" do
    Dir["test_*.rb"].each do |path|
      ruby path
    end
  end
end

RDoc::Task.new do |r|
  r.rdoc_dir = "doc"
  r.rdoc_files.include("ext/*.c", "*.rdoc", "LICENSE", "ChangeLog")
  r.title = "RBTree RDocs"
  r.main  = "README.rdoc"
end

load "rbtree-ng.gemspec"
Gem::PackageTask.new(RBTREE_NG_GEMSPEC).define

