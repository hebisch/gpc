program fjf1051a (Output);

type
  s10 = String (10);

procedure p (var s: s10);
begin
  WriteLn (s)
end;

var
  s: s10;

begin
  s := 'OK';
  p (s)
end.
