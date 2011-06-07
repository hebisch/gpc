program fjf613;

type
  a (x, y: Integer) = array [x .. x + 3 * y] of Integer;
  b (m, n: Integer) = record
    c: array [1 .. m] of Integer;
    d: a (m + n, 2);
    e: a (n, m div n);
    f: a (4, 9)
  end;

var
  w: a (2, 5);
  v: b (17, 5);
  OK: Boolean = True;
  n: Integer = 0;

procedure Check (a, b: Integer);
begin
  Inc (n);
  if a <> b then
    begin
      WriteLn ('failed ', n, ' ', a, ' ', b);
      OK := False
    end
end;

begin
  Check (w.x         , 2);
  Check (w.y         , 5);
  Check (Low    (w)  , 2);
  Check (High   (w)  , 17);
  Check (SizeOf (w)  , 18 * SizeOf (Integer));
  Check (v.m         , 17);
  Check (v.n         , 5);
  Check (Low    (v.c), 1);
  Check (High   (v.c), 17);
  Check (SizeOf (v.c), 17 * SizeOf (Integer));
  Check (v.d.x       , 22);
  Check (v.d.y       , 2);
  Check (Low    (v.d), 22);
  Check (High   (v.d), 28);
  Check (SizeOf (v.d), 9 * SizeOf (Integer));
  Check (v.e.x       , 5);
  Check (v.e.y       , 3);
  Check (Low    (v.e), 5);
  Check (High   (v.e), 14);
  Check (SizeOf (v.e), 12 * SizeOf (Integer));
  Check (v.f.x       , 4);
  Check (v.f.y       , 9);
  Check (Low    (v.f), 4);
  Check (High   (v.f), 31);
  Check (SizeOf (v.f), 30 * SizeOf (Integer));
  Check (SizeOf (v)  , 70 * SizeOf (Integer));
  if OK then WriteLn ('OK')
end.
