program fjf586;

type
  a = ^Integer;
  b = ^Integer;
  c = ^a;
  d = ^b;

var
  e: ^c;
  f: ^d;

begin
  e := f;  { WRONG }
  WriteLn ('failed')
end.
