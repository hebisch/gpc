program chief31a;

var
  v : array [1 .. 2] of String (6) = ('OK', 'Failed');

procedure p (const l : Cardinal);
begin
  WriteLn (v [l])
end;

begin
  p (1)
end.
