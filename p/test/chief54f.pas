program chief54f;
var
a : procedure;

procedure foo ();
begin
end;

begin
  a := foo (); { WRONG }
  Writeln ('failed');
end.
