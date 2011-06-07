{ FLAG -Wunused }

program fjf731a;

procedure p (a: array of Char);  { spurious warning }
begin
  WriteLn (a[0], a[1])
end;

var
  a: array [1 .. 2] of Char = 'OK';

begin
  p (a)
end.
