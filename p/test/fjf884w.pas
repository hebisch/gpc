{$W no-object-assignment}

program fjf884w;

type
  a = object
    c: Char;
  end;

  b = object (a)
    d: Char;
  end;

procedure p (t: a);
begin
  if {$local W-} (t is a) and not (t is b) {$endlocal} then
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
