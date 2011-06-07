program fjf615e;

var
  s: String (42);

procedure foo (var a: type of s.Capacity);
begin
end;

begin
  foo (s.Capacity);  { WRONG }
  WriteLn ('failed')
end.
