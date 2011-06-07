program fjf966a;

type
  t = record
    a, c: Integer;
    b: Char
  end;

  u = record
    n: Integer;
    s: String (5)
  end;

function a (v: t) = r: u;
begin
  r.n := v.c;
  r.s := Chr (v.a) + v.b
end;

begin
  with a (t[a: Ord ('O'); b: 'K'; c: 42] {$W-,borland-pascal}) do
    if n = 42 then WriteLn (s) else WriteLn ('failed')
end.
