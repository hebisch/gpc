{$borland-pascal}

program fjf796b;

type
  t = 0 .. 127;

procedure Foo (var a: Char; var b: t);
begin
  WriteLn (a, Chr (b))
end;

var
  a: packed record
    b, c: Char
  end;

  b: packed array [1 .. 2] of t;

begin
  a.c := 'O';
  b[2] := Ord ('K');
  Foo (a.c, b[2])
end.
