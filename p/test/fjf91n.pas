program fjf91n;

type
  str5 = string [5];
  str6 = str5;

procedure foo (a: str5);
begin
  WriteLn (a)
end;

var
  p: procedure (a: str6);

begin
  p := foo;
  p ('OK')
end.
