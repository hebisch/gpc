{ Not a really new test, but a `New' one. ;-}

program fjf829d;

type
  PInteger = ^Integer;
  pr = ^r;
  r = record case b: Boolean of False, True: () end;
  ps = ^s;
  s (n: Integer) = Integer;
  pt = ^t;
  t = object
    constructor r;
    destructor d;
  end;

var
  n: Integer = 0;

constructor t.r;
begin
  Inc (n)
end;

destructor t.d;
begin
  if n = 2 then WriteLn ('OK') else WriteLn ('failed')
end;

var
  a: PInteger;
  b: pr;
  c: ps;
  d: pt;

begin

  New (a);
  Dispose (a);
  a := New (PInteger);

  New (b);
  b := New (pr);
  Dispose (b);
  New (b, True);
  b := New (pr, False);
  Dispose (b, False);

  New (c, 42);
  Dispose (c);
  c := New (ps, -23);
  Dispose (c, -23);

  New (d);
  d := New (pt);
  Dispose (d);
  New (d, r);
  d := New (pt, r);
  Dispose (d, d);

end.
