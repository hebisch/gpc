program fjf806e;

type
  t = array [1 .. 1000] of Char;

function f = s: t;
begin
  s[1] := 'O';
  s[2] := 'K'
end;

procedure p (const a: t);
begin
  WriteLn (a[1], a[2])
end;

begin
  p (f)
end.
