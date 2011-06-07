program fjf91m;

type
  str5 = string [5];

procedure foo (a: str5);
begin
  WriteLn (a)
end;

var
  p: procedure (a: str5);

begin
  p := foo;
  p ('OK')
end.
