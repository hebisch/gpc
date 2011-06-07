program fjf639y;

type
  pt = ^t;
  t = object
    a: Char
  end;

  pu = ^u;
  u = object (t)
    b: Char
  end;

var
  v: pt;
  w: pu;

begin
  New (w);
  w^.a := 'O';
  w^.b := 'K';
  v := w;
  with v^ do
    WriteLn ('failed ', b, a)  { WRONG }
end.
