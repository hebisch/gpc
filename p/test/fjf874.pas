program fjf874;

procedure p (n: Integer);
type t = array [1 .. n] of Integer;

  function f = r: t;
  begin
    r[1] := 42
  end;

begin
  if f[1] = 42 then WriteLn ('OK') else WriteLn ('failed')
end;

begin

  { Backend bug. At least check that GPC avoids crashing. }
  foo  { WRONG }

  p (2)
end.
