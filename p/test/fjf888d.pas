program fjf888d;

var
  n: Integer = MaxInt div 8;

procedure Foo;
type
  t = array [1 .. n] of Char;

var
  p: ^t;
  i: Integer = 2;

begin
  GetMem (p, 10);
  p^[1 .. 3] := 'OKx';
  WriteLn (Copy (p^, 1, i))
end;

begin
  Foo
end.
