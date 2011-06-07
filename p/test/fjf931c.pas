program fjf931c;

const i = 2;

procedure p;
var
  a: array [1 .. i] of Integer;
  s: String (20) = 'OK';
begin
  a[1] := 42;
  WriteLn (s[1 .. i])
end;

begin
  p
end.
