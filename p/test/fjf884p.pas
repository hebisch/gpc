{$W no-object-assignment}

program fjf884p;

type
  a = object
    c: Integer;
  end;

var
  w, x, y: a;

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
  x.c := 17;
  y.c := -5;
  if (p.c = 42) and (q.c = 17) and (r.c = -5)
     and (TypeOf (p) = TypeOf (a))
     and (TypeOf (q) = TypeOf (a))
     and (TypeOf (r) = TypeOf (a)) then WriteLn ('OK') else WriteLn ('failed')
end.
