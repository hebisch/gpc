{$pack-struct}

program fjf797b;

type
  t = 0 .. 127;

procedure Foo (var a: t);
begin
  WriteLn (Chr (a), 'K')
end;

var
  a: array [1 .. 2] of t;

begin
  a[2] := Ord ('O');
  Foo (a[2])
end.
