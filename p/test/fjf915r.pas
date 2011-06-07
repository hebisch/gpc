program fjf915r;

type
  t (n: Integer) = Integer;
  v = 1 .. 10;

var
  a: ^t;
  i: Integer = 42;
  w: 1 .. 12;

const
  c = 17;

function f: Integer;
begin
  f := 42
end;

function g (i: Integer): Integer;
begin
  g := i
end;

begin
  New (a, Cardinal (2));
  Dispose (a, Cardinal (2));
  New (a, i);
  Dispose (a, i);
  New (a, c);
  Dispose (a, c);
  New (a, f);
  Dispose (a, f);
  New (a, g (i));
  Dispose (a, g (i));
  New (a, MaxInt);
  Dispose (a, MaxInt);
  InOutRes := 42;
  New (a, InOutRes);
  Dispose (a, InOutRes);
  InOutRes := 0;
  New (a, Sqr (2));
  Dispose (a, Sqr (2));
  New (a, ParamCount);
  Dispose (a, ParamCount);
  New (a, High (v));
  Dispose (a, High (v));
  New (a, High (w));
  Dispose (a, High (w));
  New (a, SizeOf (a));
  Dispose (a, SizeOf (a));
  New (a, SizeOf (v));
  Dispose (a, SizeOf (v));
  WriteLn ('OK')
end.
