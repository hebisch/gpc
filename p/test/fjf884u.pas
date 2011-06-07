{$W no-object-assignment}

program fjf884u;

type
  a = object
    c: Char;
  end;

  b = object (a)
    d: Char;
  end;

procedure p (protected t: a);
begin
  if TypeOf (t) = TypeOf (a) then
    Write (t.c)
  else
    Write ('Y')
end;

var
  v: a;
  w: b;

begin
  v.c := 'O';
  w.c := 'K';
  w.d := 'X';
  p (v);
  p (w);
  WriteLn
end.
