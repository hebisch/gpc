program fjf209;
type x=record a:integer end;
begin
  writeln ('failed ', sizeof(x.a))  { WRONG }
end.
