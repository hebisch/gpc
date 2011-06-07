{
The following works as a program, but not as a unit (used e.g. by an empty
program). It gives the following runtime message (DJGPP and Linux):

?GPC runtime error: (gpc-rts) _p_InitFDR() has not been called for file (#701)
}

unit fjf17u;

interface

var Lst:Text;

implementation
to begin do
begin
  Assign(Lst,'foo.dat');
  Rewrite(Lst);
  writeln(Lst,'OK');
  Close(Lst)
end;
end.
