require "./rbtree"
require "test/unit.rb"

class RBTreeTest < Test::Unit::TestCase
  def setup
    @rbtree = RBTree[*%w(b B d D a A c C)]
  end
  
  def test_new
    assert_nothing_raised {
      RBTree.new
      RBTree.new("a")
      RBTree.new { "a" }
    }
    assert_raises(ArgumentError) { RBTree.new("a") {} }
    assert_raises(ArgumentError) { RBTree.new("a", "a") }
  end
  
  def test_aref
    assert_equal("A", @rbtree["a"])
    assert_equal("B", @rbtree["b"])
    assert_equal("C", @rbtree["c"])
    assert_equal("D", @rbtree["d"])
    
    assert_equal(nil, @rbtree["e"])
    @rbtree.default = "E"
    assert_equal("E", @rbtree["e"])
  end
  
  def test_size
    assert_equal(4, @rbtree.size)
  end
  
  def test_create
    rbtree = RBTree[]
    assert_equal(0, rbtree.size)
    
    rbtree = RBTree[@rbtree]
    assert_equal(4, rbtree.size)
    assert_equal("A", @rbtree["a"])
    assert_equal("B", @rbtree["b"])
    assert_equal("C", @rbtree["c"])
    assert_equal("D", @rbtree["d"])
    
    rbtree = RBTree[RBTree.new("e")]
    assert_equal(nil, rbtree.default)
    rbtree = RBTree[RBTree.new { "e" }]
    assert_equal(nil, rbtree.default_proc)
    @rbtree.readjust {|a,b| b <=> a }
    assert_equal(nil, RBTree[@rbtree].cmp_proc)
    
    assert_raises(ArgumentError) { RBTree["e"] }
    
    rbtree = RBTree[Hash[*%w(b B d D a A c C)]]
    assert_equal(4, rbtree.size)
    assert_equal("A", rbtree["a"])
    assert_equal("B", rbtree["b"])
    assert_equal("C", rbtree["c"])
    assert_equal("D", rbtree["d"])
    
    rbtree = RBTree[[%w(a A), %w(b B), %w(c C), %w(d D)]];
    assert_equal(4, rbtree.size)
    assert_equal("A", rbtree["a"])
    assert_equal("B", rbtree["b"])
    assert_equal("C", rbtree["c"])
    assert_equal("D", rbtree["d"])
    
    rbtree = RBTree[[["a"]]]
    assert_equal(1, rbtree.size)
    assert_equal(nil, rbtree["a"])
  end
  
  def test_clear
    @rbtree.clear
    assert_equal(0, @rbtree.size)
  end
  
  def test_aset
    @rbtree["e"] = "E"
    assert_equal(5, @rbtree.size)
    assert_equal("E", @rbtree["e"])
    
    @rbtree["c"] = "E"
    assert_equal(5, @rbtree.size)
    assert_equal("E", @rbtree["c"])
    
    assert_raises(ArgumentError) { @rbtree[100] = 100 }
    assert_equal(5, @rbtree.size)
    
    
    key = "f"
    @rbtree[key] = "F"
    cloned_key = @rbtree.last[0]
    assert_equal("f", cloned_key)
    assert_not_same(key, cloned_key)
    assert_equal(true, cloned_key.frozen?)
    
    @rbtree["f"] = "F"
    assert_same(cloned_key, @rbtree.last[0])

    rbtree = RBTree.new
    key = ["g"]
    rbtree[key] = "G"
    assert_same(key, rbtree.first[0])
    assert_equal(false, key.frozen?)
  end
  
  def test_clone
    clone = @rbtree.clone
    assert_equal(4, @rbtree.size)
    assert_equal("A", @rbtree["a"])
    assert_equal("B", @rbtree["b"])
    assert_equal("C", @rbtree["c"])
    assert_equal("D", @rbtree["d"])
    
    rbtree = RBTree.new("e")
    clone = rbtree.clone
    assert_equal("e", clone.default)
    
    rbtree = RBTree.new { "e" }
    clone = rbtree.clone
    assert_equal("e", clone.default(nil))
    
    rbtree = RBTree.new
    rbtree.readjust {|a, b| a <=> b }
    clone = rbtree.clone
    assert_equal(rbtree.cmp_proc, clone.cmp_proc)
  end
  
  def test_default
    assert_equal(nil, @rbtree.default)
    
    rbtree = RBTree.new("e")
    assert_equal("e", rbtree.default)
    assert_equal("e", rbtree.default("f"))
    assert_raises(ArgumentError) { rbtree.default("e", "f") }
    
    rbtree = RBTree.new {|tree, key| @rbtree[key || "c"] }
    assert_equal("C", rbtree.default(nil))
    assert_equal("B", rbtree.default("b"))
  end
  
  def test_set_default
    rbtree = RBTree.new { "e" }
    rbtree.default = "f"
    assert_equal("f", rbtree.default)
  end
  
  def test_default_proc
    rbtree = RBTree.new("e")
    assert_equal(nil, rbtree.default_proc)
    
    rbtree = RBTree.new { "e" }
    assert_equal("e", rbtree.default_proc.call)
  end
  
  def test_equal
    assert_equal(RBTree.new, RBTree.new)
    assert_equal(@rbtree, @rbtree)
    assert_not_equal(@rbtree, RBTree.new)
    
    rbtree = RBTree[*%w(b B d D a A c C)]
    assert_equal(@rbtree, rbtree)
    rbtree["d"] = "A"
    assert_not_equal(@rbtree, rbtree)
    rbtree["d"] = "D"
    rbtree["e"] = "E"
    assert_not_equal(@rbtree, rbtree)
    @rbtree["e"] = "E"
    assert_equal(@rbtree, rbtree)
    
    rbtree.default = "e"
    assert_equal(@rbtree, rbtree)
    @rbtree.default = "f"
    assert_equal(@rbtree, rbtree)
    
    a = RBTree.new("e")
    b = RBTree.new { "f" }
    assert_equal(a, b)
    assert_equal(b, b.clone)
    
    a = RBTree.new
    b = RBTree.new
    a.readjust {|x, y| x <=> y }
    assert_not_equal(a, b)
    b.readjust(a.cmp_proc)
    assert_equal(a, b)
  end
  
  def test_fetch
    assert_equal("A", @rbtree.fetch("a"))
    assert_equal("B", @rbtree.fetch("b"))
    assert_equal("C", @rbtree.fetch("c"))
    assert_equal("D", @rbtree.fetch("d"))
    
    assert_raises(IndexError) { @rbtree.fetch("e") }
    
    assert_equal("E", @rbtree.fetch("e", "E"))
    assert_equal("E", @rbtree.fetch("e") { "E" })
    
    class << (stderr = "")
      alias write <<
    end
    $stderr, stderr, $VERBOSE, verbose = stderr, $stderr, false, $VERBOSE
    begin
      assert_equal("E", @rbtree.fetch("e", "F") { "E" })
    ensure
      $stderr, stderr, $VERBOSE, verbose = stderr, $stderr, false, $VERBOSE
    end
    assert_match(/warning: block supersedes default value argument/, stderr)
    
    assert_raises(ArgumentError) { @rbtree.fetch }
    assert_raises(ArgumentError) { @rbtree.fetch("e", "E", "E") }
  end

  def test_index
    assert_equal("a", @rbtree.index("A"))
    assert_equal(nil, @rbtree.index("E"))
  end

  def test_empty_p
    assert_equal(false, @rbtree.empty?)
    @rbtree.clear
    assert_equal(true, @rbtree.empty?)
  end
  
  def test_each
    ret = []
    @rbtree.each {|key, val| ret << key << val }
    assert_equal(%w(a A b B c C d D), ret)
    
    assert_raises(TypeError) {
      @rbtree.each { @rbtree["e"] = "E" }
    }
    assert_equal(4, @rbtree.size)
    
    @rbtree.each {
      @rbtree.each {}
      assert_raises(TypeError) {
        @rbtree["e"] = "E"
      }
      break
    }
    assert_equal(4, @rbtree.size)
    
    if defined?(Enumerable::Enumerator)
      enumerator = @rbtree.each
      assert_equal(%w(a A b B c C d D), enumerator.map.flatten)
    end
  end
  
  def test_each_pair
    ret = []
    @rbtree.each_pair {|key, val| ret << key << val }
    assert_equal(%w(a A b B c C d D), ret)

    assert_raises(TypeError) {
      @rbtree.each_pair { @rbtree["e"] = "E" }
    }
    assert_equal(4, @rbtree.size)

    @rbtree.each_pair {
      @rbtree.each_pair {}
      assert_raises(TypeError) {
        @rbtree["e"] = "E"
      }
      break
    }
    assert_equal(4, @rbtree.size)
    
    if defined?(Enumerable::Enumerator)
      enumerator = @rbtree.each_pair
      assert_equal(%w(a A b B c C d D), enumerator.map.flatten)
    end
  end
  
  def test_each_key
    ret = []
    @rbtree.each_key {|key| ret.push(key) }
    assert_equal(%w(a b c d), ret)

    assert_raises(TypeError) {
      @rbtree.each_key { @rbtree["e"] = "E" }
    }
    assert_equal(4, @rbtree.size)

    @rbtree.each_key {
      @rbtree.each_key {}
      assert_raises(TypeError) {
        @rbtree["e"] = "E"
      }
      break
    }
    assert_equal(4, @rbtree.size)
    
    if defined?(Enumerable::Enumerator)
      enumerator = @rbtree.each_key
      assert_equal(%w(a b c d), enumerator.map.flatten)
    end
  end
  
  def test_each_value
    ret = []
    @rbtree.each_value {|val| ret.push(val) }
    assert_equal(%w(A B C D), ret)

    assert_raises(TypeError) {
      @rbtree.each_value { @rbtree["e"] = "E" }
    }
    assert_equal(4, @rbtree.size)

    @rbtree.each_value {
      @rbtree.each_value {}
      assert_raises(TypeError) {
        @rbtree["e"] = "E"
      }
      break
    }
    assert_equal(4, @rbtree.size)
    
    if defined?(Enumerable::Enumerator)
      enumerator = @rbtree.each_value
      assert_equal(%w(A B C D), enumerator.map.flatten)
    end
  end

  def test_shift
    ret = @rbtree.shift
    assert_equal(3, @rbtree.size)
    assert_equal(["a", "A"], ret)
    assert_equal(nil, @rbtree["a"])
    
    3.times { @rbtree.shift }
    assert_equal(0, @rbtree.size)
    assert_equal(nil, @rbtree.shift)
    @rbtree.default = "e"
    assert_equal("e", @rbtree.shift)
    
    rbtree = RBTree.new { "e" }
    assert_equal("e", rbtree.shift)
  end
  
  def test_pop
    ret = @rbtree.pop
    assert_equal(3, @rbtree.size)
    assert_equal(["d", "D"], ret)
    assert_equal(nil, @rbtree["d"])
    
    3.times { @rbtree.pop }
    assert_equal(0, @rbtree.size)
    assert_equal(nil, @rbtree.pop)
    @rbtree.default = "e"
    assert_equal("e", @rbtree.pop)
    
    rbtree = RBTree.new { "e" }
    assert_equal("e", rbtree.pop)
  end
  
  def test_delete
    ret = @rbtree.delete("c")
    assert_equal("C", ret)
    assert_equal(3, @rbtree.size)
    assert_equal(nil, @rbtree["c"])
    
    assert_equal(nil, @rbtree.delete("e"))
    assert_equal("E", @rbtree.delete("e") { "E" })
  end
  
  def test_delete_if
    @rbtree.delete_if {|key, val| val == "A" || val == "B" }
    assert_equal(RBTree[*%w(c C d D)], @rbtree)
    
    assert_raises(ArgumentError) {
      @rbtree.delete_if {|key, val| key == "c" or raise ArgumentError }
    }
    assert_equal(2, @rbtree.size)
    
    assert_raises(TypeError) {
      @rbtree.delete_if { @rbtree["e"] = "E" }
    }
    assert_equal(2, @rbtree.size)

    @rbtree.delete_if {
      @rbtree.each {
        assert_equal(2, @rbtree.size)
      }
      assert_raises(TypeError) {
        @rbtree["e"] = "E"
      }
      true
    }
    assert_equal(0, @rbtree.size)
    
    if defined?(Enumerable::Enumerator)
      rbtree = RBTree[*%w(b B d D a A c C)]
      enumerator = rbtree.delete_if
      assert_equal([true, true, false, false], enumerator.map {|key, val| val == "A" || val == "B" })
    end
  end

  def test_reject_bang
    ret = @rbtree.reject! { false }
    assert_equal(nil, ret)
    assert_equal(4, @rbtree.size)
    
    ret = @rbtree.reject! {|key, val| val == "A" || val == "B" }
    assert_same(@rbtree, ret)
    assert_equal(RBTree[*%w(c C d D)], ret)
    
    if defined?(Enumerable::Enumerator)
      rbtree = RBTree[*%w(b B d D a A c C)]
      enumerator = rbtree.reject!
      assert_equal([true, true, false, false], enumerator.map {|key, val| val == "A" || val == "B" })
    end
  end
  
  def test_reject
    ret = @rbtree.reject { false }
    assert_equal(nil, ret)
    assert_equal(4, @rbtree.size)
    
    ret = @rbtree.reject {|key, val| val == "A" || val == "B" }
    assert_equal(RBTree[*%w(c C d D)], ret)
    assert_equal(4, @rbtree.size)
    
    if defined?(Enumerable::Enumerator)
      enumerator = @rbtree.reject
      assert_equal([true, true, false, false], enumerator.map {|key, val| val == "A" || val == "B" })
    end
  end
  
  def test_select
    ret = @rbtree.select {|key, val| val == "A" || val == "B" }
    assert_equal(%w(a A b B), ret.flatten)
    assert_raises(ArgumentError) { @rbtree.select("c") }
    
    if defined?(Enumerable::Enumerator)
      enumerator = @rbtree.select
      assert_equal([true, true, false, false], enumerator.map {|key, val| val == "A" || val == "B"})
    end
  end

  def test_values_at
    ret = @rbtree.values_at("d", "a", "e")
    assert_equal(["D", "A", nil], ret)
  end
  
  def test_invert
    assert_equal(RBTree[*%w(A a B b C c D d)], @rbtree.invert)
  end
  
  def test_update
    rbtree = RBTree.new
    rbtree["e"] = "E"
    @rbtree.update(rbtree)
    assert_equal(RBTree[*%w(a A b B c C d D e E)], @rbtree)
    
    @rbtree.clear
    @rbtree["d"] = "A"
    rbtree.clear
    rbtree["d"] = "B"
    
    @rbtree.update(rbtree) {|key, val1, val2|
      val1 + val2 if key == "d"
    }
    assert_equal(RBTree[*%w(d AB)], @rbtree)
    
    assert_raises(TypeError) { @rbtree.update("e") }
  end
  
  def test_merge
    rbtree = RBTree.new
    rbtree["e"] = "E"
    
    ret = @rbtree.merge(rbtree)
    assert_equal(RBTree[*%w(a A b B c C d D e E)], ret)
    
    assert_equal(4, @rbtree.size)
  end
  
  def test_has_key
    assert_equal(true,  @rbtree.has_key?("a"))
    assert_equal(true,  @rbtree.has_key?("b"))
    assert_equal(true,  @rbtree.has_key?("c"))
    assert_equal(true,  @rbtree.has_key?("d"))
    assert_equal(false, @rbtree.has_key?("e"))
  end
  
  def test_has_value
    assert_equal(true,  @rbtree.has_value?("A"))
    assert_equal(true,  @rbtree.has_value?("B"))
    assert_equal(true,  @rbtree.has_value?("C"))
    assert_equal(true,  @rbtree.has_value?("D"))
    assert_equal(false, @rbtree.has_value?("E"))
  end

  def test_keys
    assert_equal(%w(a b c d), @rbtree.keys)
  end

  def test_values
    assert_equal(%w(A B C D), @rbtree.values)
  end

  def test_to_a
    assert_equal([%w(a A), %w(b B), %w(c C), %w(d D)], @rbtree.to_a)
  end

  def test_to_s
    if RUBY_VERSION < "1.9"
      assert_equal("aAbBcCdD", @rbtree.to_s)
    else
      expected = "[[\"a\", \"A\"], [\"b\", \"B\"], [\"c\", \"C\"], [\"d\", \"D\"]]"
      assert_equal(expected, @rbtree.to_s)
      
      rbtree = RBTree.new
      rbtree[rbtree] = rbtree
      rbtree.default = rbtree
      expected = "[[#<RBTree: {#<RBTree: ...>=>#<RBTree: ...>}, default=#<RBTree: ...>, cmp_proc=nil>, #<RBTree: {#<RBTree: ...>=>#<RBTree: ...>}, default=#<RBTree: ...>, cmp_proc=nil>]]"
      assert_equal(expected, rbtree.to_s)
    end
  end
  
  def test_to_hash
    @rbtree.default = "e"
    hash = @rbtree.to_hash
    assert_equal(@rbtree.to_a.flatten, hash.to_a.flatten)
    assert_equal("e", hash.default)

    rbtree = RBTree.new { "e" }
    hash = rbtree.to_hash
    if (hash.respond_to?(:default_proc))
      assert_equal(rbtree.default_proc, hash.default_proc)
    else
      assert_equal(rbtree.default_proc, hash.default)
    end
  end

  def test_to_rbtree
    assert_same(@rbtree, @rbtree.to_rbtree)
  end
  
  def test_inspect
    @rbtree.default = "e"
    @rbtree.readjust {|a, b| a <=> b}
    re = /#<RBTree: (\{.*\}), default=(.*), cmp_proc=(.*)>/
    
    assert_match(re, @rbtree.inspect)
    match = re.match(@rbtree.inspect)
    tree, default, cmp_proc = match.to_a[1..-1]
    assert_equal(%({"a"=>"A", "b"=>"B", "c"=>"C", "d"=>"D"}), tree)
    assert_equal(%("e"), default)
    assert_match(/#<Proc:\w+(@#{__FILE__}:\d+)?>/o, cmp_proc)
    
    rbtree = RBTree.new
    assert_match(re, rbtree.inspect)
    match = re.match(rbtree.inspect)
    tree, default, cmp_proc = match.to_a[1..-1]
    assert_equal("{}", tree)
    assert_equal("nil", default)
    assert_equal("nil", cmp_proc)
    
    rbtree = RBTree.new
    rbtree[rbtree] = rbtree
    rbtree.default = rbtree
    match = re.match(rbtree.inspect)
    tree, default, cmp_proc =  match.to_a[1..-1]
    assert_equal("{#<RBTree: ...>=>#<RBTree: ...>}", tree)
    assert_equal("#<RBTree: ...>", default)
    assert_equal("nil", cmp_proc)
  end
  
  def test_lower_bound
    rbtree = RBTree[*%w(a A c C e E)]
    assert_equal(["c", "C"], rbtree.lower_bound("c"))
    assert_equal(["c", "C"], rbtree.lower_bound("b"))
    assert_equal(nil, rbtree.lower_bound("f"))
  end
  
  def test_upper_bound
    rbtree = RBTree[*%w(a A c C e E)]
    assert_equal(["c", "C"], rbtree.upper_bound("c"))
    assert_equal(["c", "C"], rbtree.upper_bound("d"))
    assert_equal(nil, rbtree.upper_bound("Z"))
  end
  
  def test_bound
    rbtree = RBTree[*%w(a A c C e E)]
    assert_equal(%w(a A c C), rbtree.bound("a", "c").flatten)
    assert_equal(%w(a A),     rbtree.bound("a").flatten)
    assert_equal(%w(c C e E), rbtree.bound("b", "f").flatten)

    assert_equal([], rbtree.bound("b", "b"))
    assert_equal([], rbtree.bound("Y", "Z"))
    assert_equal([], rbtree.bound("f", "g"))
    assert_equal([], rbtree.bound("f", "Z"))
  end
  
  def test_bound_block
    ret = []
    @rbtree.bound("b", "c") {|key, val|
      ret.push(key)
    }
    assert_equal(%w(b c), ret)
    
    assert_raises(TypeError) {
      @rbtree.bound("a", "d") {
        @rbtree["e"] = "E"
      }
    }
    assert_equal(4, @rbtree.size)
    
    @rbtree.bound("b", "c") {
      @rbtree.bound("b", "c") {}
      assert_raises(TypeError) {
        @rbtree["e"] = "E"
      }
      break
    }
    assert_equal(4, @rbtree.size)
  end
  
  def test_first
    assert_equal(["a", "A"], @rbtree.first)
    
    rbtree = RBTree.new("e")
    assert_equal("e", rbtree.first)

    rbtree = RBTree.new { "e" }
    assert_equal("e", rbtree.first)
  end

  def test_last
    assert_equal(["d", "D"], @rbtree.last)
    
    rbtree = RBTree.new("e")
    assert_equal("e", rbtree.last)

    rbtree = RBTree.new { "e" }
    assert_equal("e", rbtree.last)
  end

  def test_readjust
    assert_equal(nil, @rbtree.cmp_proc)
    
    @rbtree.readjust {|a, b| b <=> a }
    assert_equal(%w(d c b a), @rbtree.keys)
    assert_not_equal(nil, @rbtree.cmp_proc)
    
    proc = Proc.new {|a,b| a.to_s <=> b.to_s }
    @rbtree.readjust(proc)
    assert_equal(%w(a b c d), @rbtree.keys)
    assert_equal(proc, @rbtree.cmp_proc)
    
    @rbtree[0] = nil
    assert_raises(ArgumentError) { @rbtree.readjust(nil) }
    assert_equal(5, @rbtree.size)
    assert_equal(proc, @rbtree.cmp_proc)
    
    @rbtree.delete(0)
    @rbtree.readjust(nil)
    assert_raises(ArgumentError) { @rbtree[0] = nil }
    
    
    rbtree = RBTree.new
    key = ["a"]
    rbtree[key] = nil
    rbtree[["e"]] = nil
    key[0] = "f"

    assert_equal([["f"], ["e"]], rbtree.keys)
    rbtree.readjust
    assert_equal([["e"], ["f"]], rbtree.keys)

    assert_raises(ArgumentError) { @rbtree.readjust { "e" } }
    assert_raises(TypeError) { @rbtree.readjust("e") }
    assert_raises(ArgumentError) {
      @rbtree.readjust(proc) {|a,b| a <=> b }
    }
    assert_raises(ArgumentError) { @rbtree.readjust(proc, proc) }
  end
  
  def test_replace
    rbtree = RBTree.new { "e" }
    rbtree.readjust {|a, b| a <=> b}
    rbtree["a"] = "A"
    rbtree["e"] = "E"
    
    @rbtree.replace(rbtree)
    assert_equal(%w(a A e E), @rbtree.to_a.flatten)
    assert_equal(rbtree.default, @rbtree.default)    
    assert_equal(rbtree.cmp_proc, @rbtree.cmp_proc)

    assert_raises(TypeError) { @rbtree.replace("e") }
  end
  
  def test_reverse_each
    ret = []
    @rbtree.reverse_each { |key, val| ret.push([key, val]) }
    assert_equal(%w(d D c C b B a A), ret.flatten)
    
    if defined?(Enumerable::Enumerator)
      enumerator = @rbtree.reverse_each
      assert_equal(%w(d D c C b B a A), enumerator.map.flatten)
    end
  end
  
  def test_marshal
    assert_equal(@rbtree, Marshal.load(Marshal.dump(@rbtree)))
    
    @rbtree.default = "e"
    assert_equal(@rbtree, Marshal.load(Marshal.dump(@rbtree)))
    
    assert_raises(TypeError) {
      Marshal.dump(RBTree.new { "e" })
    }
    
    assert_raises(TypeError) {
      @rbtree.readjust {|a, b| a <=> b}
      Marshal.dump(@rbtree)
    }
  end
  
  begin
    require "pp"
    
    def test_pp
      assert_equal(%(#<RBTree: {}, default=nil, cmp_proc=nil>\n),
                   PP.pp(RBTree.new, ""))
      assert_equal(%(#<RBTree: {"a"=>"A", "b"=>"B"}, default=nil, cmp_proc=nil>\n),
                   PP.pp(RBTree[*%w(a A b B)], ""))
      
      rbtree = RBTree[*("a".."z").to_a]
      rbtree.default = "a"
      rbtree.readjust {|a, b| a <=> b }
      expected = <<EOS
#<RBTree: {"a"=>"b",
  "c"=>"d",
  "e"=>"f",
  "g"=>"h",
  "i"=>"j",
  "k"=>"l",
  "m"=>"n",
  "o"=>"p",
  "q"=>"r",
  "s"=>"t",
  "u"=>"v",
  "w"=>"x",
  "y"=>"z"},
 default="a",
 cmp_proc=#{rbtree.cmp_proc}>
EOS
      assert_equal(expected, PP.pp(rbtree, ""))

      rbtree = RBTree.new
      rbtree[rbtree] = rbtree
      rbtree.default = rbtree
      expected = <<EOS
#<RBTree: {"#<RBTree: ...>"=>"#<RBTree: ...>"},
 default="#<RBTree: ...>",
 cmp_proc=nil>
EOS
      assert_equal(expected, PP.pp(rbtree, ""))
    end
  rescue LoadError
  end
end


class MultiRBTreeTest < Test::Unit::TestCase
  def setup
    @rbtree = MultiRBTree[*%w(a A b B b C b D c C)]
  end

  def test_create
    assert_equal(%w(a A b B b C b D c C), @rbtree.to_a.flatten)
    
    assert_equal(MultiRBTree[*%w(a A)], MultiRBTree[RBTree[*%w(a A)]])
    assert_raises(TypeError) {
      RBTree[MultiRBTree[*%w(a A)]]
    }
  end

  def test_size
    assert_equal(5, @rbtree.size)
  end

  def test_clear
    @rbtree.clear
    assert_equal(0, @rbtree.size)
  end

  def test_empty
    assert_equal(false, @rbtree.empty?)
    @rbtree.clear
    assert_equal(true, @rbtree.empty?)
  end
  
  def test_to_a
    assert_equal([%w(a A), %w(b B), %w(b C), %w(b D), %w(c C)],
                 @rbtree.to_a)
  end

  def test_to_s
    if RUBY_VERSION < "1.9"
      assert_equal("aAbBbCbDcC", @rbtree.to_s)
    else
      expected = "[[\"a\", \"A\"], [\"b\", \"B\"], [\"b\", \"C\"], \[\"b\", \"D\"], [\"c\", \"C\"]]"
      assert_equal(expected, @rbtree.to_s)
    end
  end
  
  def test_to_hash
    assert_raises(TypeError) {
      @rbtree.to_hash
    }
  end

  def test_to_rbtree
    assert_equal(@rbtree, @rbtree.to_rbtree)
  end

  def test_aref
    assert_equal("B", @rbtree["b"])
  end

  def test_aset
    @rbtree["b"] = "A"
    assert_equal("B", @rbtree["b"])
    assert_equal(%w(a A b B b C b D b A c C), @rbtree.to_a.flatten)
  end

  def test_equal
    assert_equal(true, MultiRBTree[*%w(a A b B b C b D c C)] == @rbtree)
    assert_equal(true, RBTree[*%w(a A)] == MultiRBTree[*%w(a A)])
    assert_equal(true, MultiRBTree[*%w(a A)] == RBTree[*%w(a A)])
  end
  
  def test_replace
    assert_equal(RBTree[*%w(a A)],
                 MultiRBTree[*%w(a A)].replace(RBTree[*%w(a A)]))
    assert_raises(TypeError) {
      RBTree[*%w(a A)].replace(MultiRBTree[*%w(a A)])
    }
  end

  def test_update
    assert_equal(MultiRBTree[*%w(a A b B)],
                 MultiRBTree[*%w(a A)].update(RBTree[*%w(b B)]))
    assert_raises(TypeError) {
      RBTree[*%w(a A)].update(MultiRBTree[*%w(b B)])
    }
  end

  def test_clone
    assert_equal(@rbtree, @rbtree.clone)
  end
  
  def test_each
    ret = []
    @rbtree.each {|k, v|
      ret << k << v
    }
    assert_equal(%w(a A b B b C b D c C), ret)
  end

  def test_delete
    @rbtree.delete("b")
    assert_equal(4, @rbtree.size)
    assert_equal(%w(a A b C b D c C), @rbtree.to_a.flatten)

    @rbtree.delete("b")
    assert_equal(3, @rbtree.size)
    assert_equal(%w(a A b D c C), @rbtree.to_a.flatten)

    @rbtree.delete("b")
    assert_equal(2, @rbtree.size)
    assert_equal(%w(a A c C), @rbtree.to_a.flatten)
  end

  def test_delete_if
    @rbtree.delete_if {|k, v| k == "b" }
    assert_equal(%w(a A c C), @rbtree.to_a.flatten)
  end

  def test_inspect
    assert_equal(%(#<MultiRBTree: {"a"=>"A", "b"=>"B", "b"=>"C", "b"=>"D", "c"=>"C"}, default=nil, cmp_proc=nil>),
                 @rbtree.inspect)
  end

  def test_readjust
    @rbtree.readjust {|a, b| b <=> a }
    assert_equal(%w(c C b B b C b D a A), @rbtree.to_a.flatten)
  end
  
  def test_marshal
    assert_equal(@rbtree, Marshal.load(Marshal.dump(@rbtree)))
  end

  def test_lower_bound
    assert_equal(%w(b B), @rbtree.lower_bound("b"))
  end

  def test_upper_bound
    assert_equal(%w(b D), @rbtree.upper_bound("b"))
  end

  def test_bound
    assert_equal(%w(b B b C b D), @rbtree.bound("b").flatten)
  end
  
  def test_first
    assert_equal(%w(a A), @rbtree.first)
  end

  def test_last
    assert_equal(%w(c C), @rbtree.last)
  end

  def test_shift
    assert_equal(%w(a A), @rbtree.shift)
    assert_equal(4, @rbtree.size)
    assert_equal(nil, @rbtree["a"])
  end

  def test_pop
    assert_equal(%w(c C), @rbtree.pop)
    assert_equal(4, @rbtree.size)
    assert_equal(nil, @rbtree["c"])
  end

  def test_has_key
    assert_equal(true,  @rbtree.has_key?("b"))
  end

  def test_has_value
    assert_equal(true, @rbtree.has_value?("B"))
    assert_equal(true, @rbtree.has_value?("C"))
    assert_equal(true, @rbtree.has_value?("D"))
  end

  def test_select
    assert_equal(%w(b B b C b D), @rbtree.select {|k, v| k == "b"}.flatten)
    assert_equal(%w(b C c C),     @rbtree.select {|k, v| v == "C"}.flatten)
  end

  def test_values_at
    assert_equal(%w(A B), @rbtree.values_at("a", "b"))
  end

  def test_invert
    assert_equal(MultiRBTree[*%w(A a B b C b C c D b)], @rbtree.invert)
  end

  def test_keys
    assert_equal(%w(a b b b c), @rbtree.keys)
  end

  def test_values
    assert_equal(%w(A B C D C), @rbtree.values)
  end

  def test_index
    assert_equal("b", @rbtree.index("B"))
    assert_equal("b", @rbtree.index("C"))
    assert_equal("b", @rbtree.index("D"))
  end
end

class TestNodes < Test::Unit::TestCase
  def setup
    @rbtree = RBTree[*%w(b B d D a A c C)]
  end
  
  def test_first_node
    node = @rbtree.first_node
    assert_kind_of(RBTree::Node, node)
    assert_equal("a", node.key)
    assert_equal("A", node.value)
    
    # Invariant under addition
    @rbtree["A1"] = "a1"
    assert_kind_of(RBTree::Node, node)
    assert_equal("a", node.key)
    assert_equal("A", node.value)

    # If the addition is before the first node, previously defined nodes remain unchanged
    assert "0" < "A" # Just to be sure the test is testing what we think it should
    @rbtree["0"] = "zero"
    assert_kind_of(RBTree::Node, node)
    assert_equal("a", node.key)
    assert_equal("A", node.value)
    
    # But, the first node has now changed
    node2 = @rbtree.first_node
    assert_kind_of(RBTree::Node, node2)
    assert_equal("0", node2.key)
    assert_equal("zero", node2.value)
    
    # If the value underlying a node changes, so does the node
    @rbtree["a"] = "q"
    assert_equal("q", node.value)
    
    # Returns nil if no elements in the tree
    tree2 = RBTree[]
    node3 = tree2.first_node
    assert_nil node3
    
    # NOTE: behavior under deletion is undefined, and probably pathological. Don't do this:
    #  t = RBTree.new
    #  t['a'] = 'A'
    #  n = t.first_node
    #  t.delete('a')
    #  n.key # Because n used to point to a node which has now been deleted. The result is undefined, and may go boom!
    
  end
  
  def test_last_node
    node = @rbtree.last_node
    assert_kind_of(RBTree::Node, node)
    assert_equal("d", node.key)
    assert_equal("D", node.value)
    
    # Invariant under addition
    @rbtree["c1"] = "C1"
    assert_kind_of(RBTree::Node, node)
    assert_equal("d", node.key)
    assert_equal("D", node.value)

    # If the addition is before the last node, previously defined nodes remain unchanged
    @rbtree["e"] = "E"
    assert_kind_of(RBTree::Node, node)
    assert_equal("d", node.key)
    assert_equal("D", node.value)
    
    # But, the last node has now changed
    node2 = @rbtree.last_node
    assert_kind_of(RBTree::Node, node2)
    assert_equal("e", node2.key)
    assert_equal("E", node2.value)
    
    # If the value underlying a node changes, so does the node
    @rbtree["d"] = "q"
    assert_equal("q", node.value)
    
    # Returns nil if no elements in the tree
    tree2 = RBTree[]
    node3 = tree2.last_node
    assert_nil node3
    
    # NOTE: behavior under deletion is undefined, and probably pathological. Don't do this:
    #  t = RBTree.new
    #  t['a'] = 'A'
    #  n = t.last_node
    #  t.delete('a')
    #  n.key # Because n used to point to a node which has now been deleted. The result is undefined, and may go boom!
    
  end
  
  def test_fetch_node
    node = @rbtree.fetch_node("c")
    assert_kind_of(RBTree::Node, node)
    assert_equal("c", node.key)
    assert_equal("C", node.value)
    
    # Invariant under addition before
    @rbtree["b1"] = "B1"
    assert_kind_of(RBTree::Node, node)
    assert_equal("c", node.key)
    assert_equal("C", node.value)

    # Invariant under addition after
    @rbtree["c1"] = "C1"
    assert_kind_of(RBTree::Node, node)
    assert_equal("c", node.key)
    assert_equal("C", node.value)
    
    # If the value underlying a node changes, so does the node
    @rbtree["c"] = "q"
    assert_equal("q", node.value)
    
    # Returns nil if no elements in the tree
    tree2 = RBTree[]
    node3 = tree2.fetch_node("A")
    assert_nil node3
    
    # Returns nil if no matching element in the tree
    node4 = tree2.fetch_node("q")
    assert_nil node4
    
    # NOTE: behavior under deletion is undefined, and probably pathological. Don't do this:
    #  t = RBTree.new
    #  t['a'] = 'A'
    #  n = t.last_node
    #  t.delete('a')
    #  n.key # Because n used to point to a node which has now been deleted. The result is undefined, and may go boom!
    
  end
  
  def test_next
    @rbtree["e"] = "E"
    n3 = @rbtree.fetch_node("c")
    n4 = n3.next
    assert_kind_of(RBTree::Node, n4)
    assert_equal("d", n4.key)
    assert_equal("D", n4.value)
    
    n5 = n4.next
    assert_kind_of(RBTree::Node, n5)
    assert_equal("e", n5.key)
    assert_equal("E", n5.value)
    
    n6 = n5.next
    assert_nil n6 # Past end of tree
    
    # Note that each invocation of next returns a new Node object:
    n4_b = n3.next
    assert !(n4_b.equal?(n4))
    assert_equal n4.key, n4_b.key
    assert_equal n4.value, n4_b.value
    
    n4_c = n5.prev
    assert !(n4_c.equal?(n4))
    assert_equal n4.key, n4_c.key
    assert_equal n4.value, n4_c.value
    
    # If we add before a node, next doesn't change
    @rbtree["b1"] = "B1"
    n4_d = n3.next
    assert_kind_of(RBTree::Node, n4_d)
    assert_equal("d", n4_d.key)
    assert_equal("D", n4_d.value)
    
    # If we add after a node, next changes
    @rbtree["c1"] = "C1"
    n4_e = n3.next
    assert_kind_of(RBTree::Node, n4_e)
    assert_equal("c1", n4_e.key)
    assert_equal("C1", n4_e.value)
    # And the linkages still work
    n5_b = n4_e.next
    assert_kind_of(RBTree::Node, n5_b)
    assert_equal("d", n5_b.key)
    assert_equal("D", n5_b.value)
    # Note that the old node still points where it always did
    assert_equal("d", n4.key)
    assert_equal("D", n4.value)
    assert !(n4.equal?(n5_b))
    
    # If we delete a node before another node, next doesn't change
    @rbtree.delete("b1")
    n4_f = n3.next
    assert_kind_of(RBTree::Node, n4_f)
    assert_equal("c1", n4_f.key)
    assert_equal("C1", n4_f.value)
    
    # If we add after a node, next changes
    @rbtree.delete("c1")
    n4_g = n3.next
    assert_kind_of(RBTree::Node, n4_g)
    assert_equal("d", n4_g.key)
    assert_equal("D", n4_g.value)
    # Note that the old node still points where it always did
    assert_equal("d", n5_b.key)
    assert_equal("D", n5_b.value)
    assert !(n4_g.equal?(n5_b))
    # BUT BE CAREFUL, because n4_e is now undefined!
  end
  
  def test_prev
    n3 = @rbtree.fetch_node("c")
    n2 = n3.prev
    assert_kind_of(RBTree::Node, n2)
    assert_equal("b", n2.key)
    assert_equal("B", n2.value)
    
    n1 = n2.prev
    assert_kind_of(RBTree::Node, n1)
    assert_equal("a", n1.key)
    assert_equal("A", n1.value)
    
    n0 = n1.prev
    assert_nil n0 # Past beginning of tree
    
    # Note that each invocation of prev returns a new Node object:
    n2_b = n3.prev
    assert !(n2_b.equal?(n2))
    assert_equal n2.key, n2_b.key
    assert_equal n2.value, n2_b.value
    
    n2_c = n1.next
    assert !(n2_c.equal?(n2))
    assert_equal n2.key, n2_c.key
    assert_equal n2.value, n2_c.value
    
    # If we add after a node, prev doesn't change
    @rbtree["c1"] = "C1"
    n2_d = n3.prev
    assert_kind_of(RBTree::Node, n2_d)
    assert_equal("b", n2_d.key)
    assert_equal("B", n2_d.value)
    
    # If we add before a node, prev changes
    @rbtree["b1"] = "B1"
    n2_e = n3.prev
    assert_kind_of(RBTree::Node, n2_e)
    assert_equal("b1", n2_e.key)
    assert_equal("B1", n2_e.value)
    # And the linkages still work
    n1_b = n2_e.prev
    assert_kind_of(RBTree::Node, n1_b)
    assert_equal("b", n1_b.key)
    assert_equal("B", n1_b.value)
    # Note that the old node still points where it always did
    assert_equal("b", n2.key)
    assert_equal("B", n2.value)
    assert !(n2.equal?(n1_b))
    
    # If we delete a node after another node, prev doesn't change
    @rbtree.delete("c1")
    n2_f = n3.prev
    assert_kind_of(RBTree::Node, n2_f)
    assert_equal("b1", n2_f.key)
    assert_equal("B1", n2_f.value)
    
    # If we add after a node, prev changes
    @rbtree.delete("b1")
    n2_g = n3.prev
    assert_kind_of(RBTree::Node, n2_g)
    assert_equal("b", n2_g.key)
    assert_equal("B", n2_g.value)
    # Note that the old node still points where it always did
    assert_equal("b", n2_b.key)
    assert_equal("B", n2_b.value)
    assert !(n2_g.equal?(n2_b))
    # BUT BE CAREFUL, because n2_e is now undefined!
  end
  
  def test_each_node
    ret = []
    retval = @rbtree.each_node {|node| ret << node }
    assert retval.equal?(@rbtree)
    assert_equal 4, ret.size
    non_nodes = ret.select {|x| x.class != RBTree::Node}
    assert_equal 0, non_nodes.size
    ret2 = []
    ret.each {|node| ret2 << node.key << node.value }
    assert_equal(%w(a A b B c C d D), ret2)
    
    assert_raises(TypeError) {
      @rbtree.each_node { @rbtree["e"] = "E" }
    }
    assert_equal(4, @rbtree.size)
    
    @rbtree.each_node {
      @rbtree.each_node {}
      assert_raises(TypeError) {
        @rbtree["e"] = "E"
      }
      break
    }
    assert_equal(4, @rbtree.size)
    
    if defined?(Enumerable::Enumerator)
      enumerator = @rbtree.each_node
      assert_equal(%w(a A b B c C d D), enumerator.map{|node| [node.key, node.value]}.flatten)
    end
  end
  
  def test_reverse_each_node
    ret = []
    retval = @rbtree.reverse_each_node {|node| ret << node }
    assert retval.equal?(@rbtree)
    assert_equal 4, ret.size
    non_nodes = ret.select {|x| x.class != RBTree::Node}
    assert_equal 0, non_nodes.size
    ret2 = []
    ret.each {|node| ret2 << node.key << node.value }
    assert_equal(%w(d D c C b B a A), ret2)
    
    assert_raises(TypeError) {
      @rbtree.reverse_each_node { @rbtree["e"] = "E" }
    }
    assert_equal(4, @rbtree.size)
    
    @rbtree.reverse_each_node {
      @rbtree.reverse_each_node {}
      assert_raises(TypeError) {
        @rbtree["e"] = "E"
      }
      break
    }
    assert_equal(4, @rbtree.size)
    
    if defined?(Enumerable::Enumerator)
      enumerator = @rbtree.reverse_each_node
      assert_equal(%w(d D c C b B a A), enumerator.map{|node| [node.key, node.value]}.flatten)
    end
  end
end
