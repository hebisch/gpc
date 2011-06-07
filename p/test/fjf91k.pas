program fjf91k;

type
  str5 = string [5];
  str6 = string [5];

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
