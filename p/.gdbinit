# GDB macros, useful for debugging GPC
# Author: Frank Heckenbach <frank@pascal.gnu.de>

define pt
print debug_tree ($arg0), $arg0
end
document pt
Print (using `debug_tree') the tree node that is $arg0.
end

define bk
pt $$
end
document bk
Print the tree node before the last one again.
end

define chain
pt $->common.chain
end
document chain
Print the TREE_CHAIN of a tree node.
end

define type
pt $->common.type
end
document type
Print the TREE_TYPE of a tree node.
end

define tv
pt $->type.values
end
document tv
Print the TYPE_VALUES, TYPE_DOMAIN, TYPE_FIELDS or TYPE_ARG_TYPES of a tree node.
end

define value
pt $->common.code==TREE_LIST?$->list.value:0
end
document value
Print the TREE_VALUE of a TREE_LIST node.
end

define purpose
pt $->common.code==TREE_LIST?$->list.purpose:0
end
document purpose
Print the TREE_PURPOSE of a TREE_LIST node.
end

define operand
pt $->exp.operands[$arg0]
end
document operand
Print the TREE_OPERAND($arg0) of an expression node.
end

# Make gdb complain about symbol reading errors.  This is so that gcc
# developers can see and fix bugs in gcc debug output.
#set complaints 20

b error
b error_with_decl
b error_with_file_and_line
b internal_error
b exit
