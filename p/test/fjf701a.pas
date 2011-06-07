program fjf701a;

label 99;

procedure Foo;
begin
  goto 99;  { WRONG }
end;

begin
  repeat
    Foo;
    99: WriteLn ('failed')
  until True
end.
