{$extended-pascal}

program fjf1098b (Output);

type
  s = String (20);

procedure p (var a: s);
begin
  Write (a)
end;

var
  v: ^s;
  w: ^String;

begin
  New (v);
  v^ := 'O';
  p (v^);
  New (w, 20);
  w^ := 'K';
  p (w^);
  WriteLn
end.
