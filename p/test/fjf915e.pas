program fjf915e;

type
  t = object
    i: Integer;
    constructor Init (a, b, c, d: Boolean);
    constructor Init2 (e: Boolean);
    destructor Done (e: Integer); virtual;
    destructor Done2 (a, b, c, d: Integer); virtual;
  end;

constructor t.Init (a, b, c, d: Boolean);
begin
  i := Ord (a) + 2 * Ord (b) + 4 * Ord (c) + 8 * Ord (d)
end;

constructor t.Init2 (e: Boolean);
begin
  i := 16 + Ord (e)
end;

destructor t.Done;
begin
  if (e <> 4) or (i <> 6) then WriteLn ('failed 1')
end;

destructor t.Done2 (a, b, c, d: Integer);
begin
  if (a <> 1) or (b <> 3) or (c <> 4) or (d <> 5) or (i <> 7) then WriteLn ('failed 2')
end;

function Init (a: Boolean): Boolean;
begin
  Init := not a
end;

function Init2 (a: Boolean): Boolean;
begin
  Init2 := not a
end;

type
  pp = ^t;
  s (b: Boolean) = Integer;

var
  p: ^t;
  ps: ^s;

begin
  p := New (pp, Init (False, True, True, False));
  Dispose (p, Done (4));
  New (p, Init (Init (False), True, True, False));
  Dispose (p, Done2 (1, 3, 4, 5));
  New (p, Init2 (Init2 (False)));
  New (ps, Init2 (Init2 (False)));
  if (p^.i = 17) and not ps^.b then WriteLn ('OK') else WriteLn ('failed ', p^.i, ' ', ps^.b)
end.
