program fjf995b;

type
  t = array [Chr (2) .. Chr (4)] of Char;

var
  v: t;
  p: ^t;
  c: Char = Chr (3);

begin
  p := @v;
  v[Chr (3)] := 'O';
  v[Chr (4)] := 'K';
  WriteLn (p^[c], p^[Succ (c)])
end.
