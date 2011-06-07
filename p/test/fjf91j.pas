program fjf91j;

type
  str5 = string [5];
  str6 = string [6];

procedure foo (a: str5);
begin
  WriteLn (a)
end;

var
  p: procedure (a: str6);

begin
  p := foo;  { WRONG }
  WriteLn ('failed')
end.
