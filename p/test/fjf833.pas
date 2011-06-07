program fjf833;

type
  p = ^Integer;

function a = r: Integer;
var b: p;
begin
  b := @r;
  b^ := 42
end;

type
  s42 = String (42);

function b = s: s42;
begin
  Str (42, s)
end;

begin
  if (a = 42) and (b = '42') then WriteLn ('OK') else WriteLn ('failed')
end.
