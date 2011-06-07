program fjf884c2;

type
  a = object
    c: Char;
  end;

  b = object (a)
    d: Char;
  end;

procedure p (var t: a);
begin
  if TypeOf (t) = TypeOf (a) then
    Write (t.c)
  else
    Write ('K')
end;

var
  v: a;
  w: b;

begin
  v.c := 'O';
  w.c := 'Y';
  w.d := 'X';
  p (v);
  p (w);
  WriteLn
end.
