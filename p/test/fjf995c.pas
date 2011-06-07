program fjf995c;

type
  ta = array [Chr (2) .. Chr (4)] of Char;
  pa = ^ta;
  t (u: Char) = array [Chr (2) .. u] of Char;

var
  v: t (Chr (4));
  p: ^ta;
  c: Char = Chr (3);

begin
  p := pa (@v[Chr(2)]);
  v[Chr (3)] := 'O';
  v[Chr (4)] := 'K';
  WriteLn (p^[c], p^[Succ (c)])
end.
