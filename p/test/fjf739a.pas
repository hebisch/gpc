program fjf739a;

type
  s (b: Integer) = Integer;
  d = s (42);

procedure g (a: Integer);
begin
  WriteLn ('g ', a)
end;

function x = c: d;
begin
  c := 11
end;

var
  b: d;
  e: array [1 .. 10] of d;
  f: record g: d end;
  h: ^d = @b;

begin
  e[2] := 3;
  f.g := 5;
  b := 7;
  WriteLn (b);
  WriteLn (b.b);
  WriteLn (x);
  WriteLn (x.b);
  WriteLn (e[2]);
  WriteLn (e[2].b);
  WriteLn (f.g);
  WriteLn (f.g.b);
  WriteLn (h^);
  WriteLn (h^.b);
  g (b);
  g (b.b);
  g (x);
  g (x.b);
  g (e[2]);
  g (e[2].b);
  g (f.g);
  g (f.g.b);
  g (h^);
  g (h^.b);
end.
