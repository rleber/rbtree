require 'mkmf'

$defs << '-DNDEBUG'
have_header('ruby/st.h')
have_func('rb_exec_recursive', 'ruby.h')
create_makefile('rbtree')
