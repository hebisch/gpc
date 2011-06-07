program chief31c;

var
  v : array [1 .. 2] of String (6) = ('OK', 'Failed');

procedure p (const l : Integer);
begin
  WriteLn (v [l])
end;

begin
  p (1)
end.
