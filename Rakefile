# -*- ruby -*-
require "rubygems/package_task"

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
      ruby "-I../ext #{path}"
    end
  end
end

load "rbtree-ng.gemspec"
Gem::PackageTask.new(RBTREE_NG_GEMSPEC).define
