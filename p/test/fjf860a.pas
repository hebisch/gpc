{ FLAG -Wunused }

{ No unused warnings due to type attributes. }

program fjf860a;

type
  a = Integer attribute (unused);
  b (n: Integer) = Integer attribute (unused);

var
  va: a;
  vb: b (42);
  vc: Integer attribute (unused); attribute (static);

const
  vd: Integer attribute (unused) = 42;

begin
  WriteLn ('OK')
end.
