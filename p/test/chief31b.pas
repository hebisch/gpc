program chief31b;

var
  v : array [1 .. 2] of String (6) = ('OK', 'Failed');

procedure p (protected l : Cardinal);
begin
  WriteLn (v [l])
end;

begin
  p (1)
end.
