program chief54e;
var
a : procedure;
procedure foo ();
begin
end;
begin
  a () := foo; { WRONG }
  Writeln ('failed');
end.
