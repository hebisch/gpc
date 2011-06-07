program fjf915s;

type
  v = 1 .. 1200;
  t = record
      case n: Integer of
        1, 400, 1700, 1000, 1200, MaxInt,
        Min (SizeOf (Pointer), SizeOf (v)) ..
        Max (SizeOf (Pointer), SizeOf (v)): ()
      end;

var
  a: ^t;
  w: 1 .. 1000;

const
  c = 1700;

begin
  New (a, Cardinal (1));
  Dispose (a, Cardinal (1));
  New (a, c);
  Dispose (a, c);
  New (a, MaxInt);
  Dispose (a, MaxInt);
  New (a, Sqr (20));
  Dispose (a, Sqr (20));
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

