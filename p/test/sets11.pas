Program Sets11;

Var
  A: set of Char = [ 'A' ];
  B: set of Byte = [ ord ( 'A' ) ];

begin
  if A = B then  { WRONG }
    writeln ( 'failed' )
  else
    writeln ( 'failed totally' )
end.
