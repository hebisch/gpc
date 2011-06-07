{ FLAG -O0 -g0 }  { O <= 2, g <= 1 }

program fjf627;

var
  s: String (42) = '';
  i: Integer;

procedure p (const x: String);
begin
  s := x
end;

begin
  p ('a' + s);
  for i := 1 to 10 do
    p ('a' + s);
  if s = 'aaaaaaaaaaa' then WriteLn ('OK') else WriteLn ('failed')
end.
