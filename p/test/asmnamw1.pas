Program AsmNameW1;

Var
  OK: String ( 10 ); attribute (name = 's 2');  { WRONG }

begin
  writeln ( 'failed' );
end.
