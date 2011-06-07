program fjf116;
Var S:String ( 42 );
begin
  Dec(S[0]);  { WRONG }
  writeln ( 'failed' );
end.
