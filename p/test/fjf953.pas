program fjf953;

procedure foo;
var a: String(20) = ''; attribute (static);
begin
  Write (a);
  a := 'K'
end;

procedure bar;
var a: String(40) = ''; attribute (static);
begin
  Write (a);
  a := 'O'
end;

begin
  foo;
  bar;
  bar;
  foo;
  WriteLn
end.
