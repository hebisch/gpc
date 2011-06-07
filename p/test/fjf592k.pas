program fjf592k;

type
  t (Count: Cardinal) = array [1 .. 10] of String (42);

procedure p (x: t); forward;

procedure p (x: t);
var i: Integer;
begin
  for i := 1 to x.Count do Write (x[i]);
  WriteLn
end;

var
  a: t (2);

begin
  a[2] := 'K';
  a[1] := 'O';
  p (a)
end.
