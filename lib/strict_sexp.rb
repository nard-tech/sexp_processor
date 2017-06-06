##
# I'm starting to warm up to this idea!
# ENV["STRICT_SEXP"] turns on various levels of conformance checking
#
# 1 = sexp[0]         => sexp_type
# 1 = sexp.first      => sexp_type
# 1 = sexp[0] = x     => sexp_type = x
# 1 = sexp[1..-1]     => sexp_body
# 1 = sexp[1..-1] = x => sexp_body = x
# 1 = sexp[-1]        => last
# 2 = sexp[1]         => no
# 2 = sexp[1] = x     => no
# 3 = sexp[n]         => no
# 3 = sexp[n] = x     => no
# 3 = sexp.node_name  => no (ie, method_missing)
# 4 = sexp.replace x  => no
# 4 = sexp.concat x   => no
# 4 = sexp.collect!   => no
# 4 = sexp.compact!   => no
# 4 = sexp.flatten!   => no
# 4 = sexp.map!       => no
# 4 = sexp.reject!    => no
# 4 = sexp.reverse!   => no
# 4 = sexp.rotate!    => no
# 4 = sexp.select!    => no
# 4 = sexp.shuffle!   => no
# 4 = sexp.slice!     => no
# 4 = sexp.sort!      => no
# 4 = sexp.sort_by!   => no
# 4 = sexp.uniq!      => no
# 4 = sexp.unshift    => no
# 4 = sexp.push       => no
# 4 = sexp.pop        => no

class Sexp
  alias :safe_idx   :[]
  alias :safe_asgn  :[]=
  alias :sexp_type= :sexp_type=
  alias :sexp_body= :sexp_body=

  def self.nuke_method name, level
    define_method name do |*args|
      raise "no: %p.%s %p" % [self, name, args]
    end if __strict >= level
  end

  def self.__strict
    ENV["STRICT_SEXP"].to_i
  end

  def __strict
    self.class.__strict
  end

  undef_method :method_missing if __strict > 2

  def method_missing msg, *args
    raise "don't call method_missing on Sexps: %p.(%s)" % [msg, args.inspect[1..-2]]
  end if __strict > 2

  def [] i
    raise "use sexp_type" if i == 0
    raise "use sexp_body" if i == (1..-1)
    raise "use last" if i == -1
    raise "no idx>1: #{inspect}[#{i}]" if Integer === i && i > 1 if __strict > 1
    raise "no idx: #{inspect}[#{i}]" if __strict > 2
    self.safe_idx i
  end

  def []= i, v
    raise "use sexp_type=" if i == 0
    raise "use sexp_body=" if i == (1..-1)
    raise "no asgn>1: #{inspect}[#{i}] = #{v.inspect}" if Integer === i && i > 1 if
      __strict > 1
    raise "no asgn: #{inspect}[#{i}] = #{v.inspect}" if
      __strict > 2
    self.safe_asgn i, v
  end

  def first
    raise "use sexp_type"
  end

  nuke_method :replace,  4
  nuke_method :concat,   4
  nuke_method :collect!, 4
  nuke_method :compact!, 4
  nuke_method :flatten!, 4
  nuke_method :map!,     4
  nuke_method :reject!,  4
  nuke_method :reverse!, 4
  nuke_method :rotate!,  4
  nuke_method :select!,  4
  nuke_method :shuffle!, 4
  nuke_method :slice!,   4
  nuke_method :sort!,    4
  nuke_method :sort_by!, 4
  nuke_method :uniq!,    4
  nuke_method :unshift,  4
  nuke_method :push,     4
  nuke_method :pop,      4

  def sexp_type
    safe_idx 0
  end

  def sexp_body from = 1
    safe_idx from..-1
  end

  def sexp_type= v
    self.safe_asgn 0, v
  end

  def sexp_body= v
    self.safe_asgn 1..-1, v
  end
end unless Sexp.new.respond_to? :safe_asgn if ENV["STRICT_SEXP"]
