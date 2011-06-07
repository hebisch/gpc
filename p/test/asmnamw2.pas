Program AsmNamW2;

Procedure Foo; external name 'this is wrong';  { WRONG }

begin
  writeln ( 'failed' );
end.
