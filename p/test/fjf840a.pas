program fjf840a (Output);

const
  s = 'ABC';

type
  t = String (100);
  u = array [1 .. 2] of Integer;
  v = record f: Integer end;

function f: t;
begin
  f := 'MNO'
end;

function g = r: u;
begin
  r[1] := Ord ('K');
  r[2] := Ord ('X')
end;

function h = r: v;
begin
  r.f := 42
end;

begin
  if (s[1] = 'A') and (s[2 .. 3] = 'BC') and (h.f = 42) and (f[1 .. 2] = 'MN') then
    WriteLn (f[3], Chr (g[1]))
  else
    WriteLn ('failed')
end.
