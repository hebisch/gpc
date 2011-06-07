program chief54g;
var
a : procedure;

procedure dummy;
begin
end;

procedure foo ();
begin
  a ();
  a;
end;

begin
  a := dummy;
  a;
  a ();
  foo;
  foo ();
  a := foo;
  Writeln ('OK');
end.
