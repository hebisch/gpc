program Foo (Output);

type
  EmptyType = record end;

var
  F: file of EmptyType;

begin
  rewrite (F);
  { F^ := EmptyType[]; }
  put (F);
  reset (F);
  get (F);
  writeln ('OK')
end.
