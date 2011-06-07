{$W no-object-assignment}

program fjf884v;

type
  a = object
    c: Char;
  end;

  b = object (a)
    d: Char;
    e: Integer;
  end;

procedure p (t: a);
begin
  if SizeOf (t) = SizeOf (a) then
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
