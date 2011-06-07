{ Some rather strange kinds of schema types ... }

program fjf589a;

type
  x (n: Cardinal) = Integer;
  t = array [1 .. 2] of Integer;
  p = ^t;
  q (n: Cardinal) = String (n);
  qq (n: Cardinal) = String (12);

var
  y: x (1);
  z: ^x;
  OK: Boolean = True;
  v: q (42);
  w: ^q;
  vv: qq (42);
  ww: ^qq;

procedure Check (a, b: Integer);
var c: Integer = 0; attribute (static);
begin
  Inc (c);
  if a <> b then
    begin
      WriteLn ('failed ', c, ' ', a, ' ', b);
      OK := False
    end
end;

begin
  Check (Low (y), Low (Integer));
  Check (High (y), MaxInt);
  Check (y.n, 1);
  y := 3;
  Check (y.n, 1);
  Check (y, 3);
  New (z, 3);
  Check (Low (z^), Low (Integer));
  Check (High (z^), High (Integer));
  Check (z^.n, 3);
  z^ := 5;
  Check (z^.n, 3);
  Check (z^, 5);
  { With `--pack-struct', x has (formally) smaller alignment (1) than than t
    (alignment of Integer). The cast to `Pointer' avoids a warning in this case. }
  Check (p (Pointer (z))^[1], 3);
  Check (p (Pointer (z))^[2], 5);
  Check (Low (v), 1);
  Check (High (v), 42);
  New (w, 99);
  Check (Low (w^), 1);
  Check (High (w^), 99);
  Check (Low (vv), 1);
  Check (High (vv), 12);
  New (ww, 99);
  Check (Low (ww^), 1);
  Check (High (ww^), 12);
  if OK then WriteLn ('OK')
end.
