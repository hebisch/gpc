{$W no-object-assignment}

program fjf884s;

type
  a = object
    c: Integer;
  end;

  b = object (a)
    d: Integer;
  end;

var
  w, x, y: b;

function p: a;
begin
  p := w
end;

function q = v: a;
begin
  v := x
end;

function r: a;
begin
  Return y
end;

begin
  w.c := 42;
  w.d := 19;
  x.c := 17;
  x.d := -7;
  y.c := -5;
  y.d := 99;
  if (p.c = 42) and (q.c = 17) and (r.c = -5)
     and (TypeOf (p) = TypeOf (a))
     and (TypeOf (q) = TypeOf (a))
     and (TypeOf (r) = TypeOf (a)) then WriteLn ('OK') else WriteLn ('failed')
end.
