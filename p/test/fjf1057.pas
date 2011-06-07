program fjf1057 (Output);

type s = String (10);

function f: s;
begin
  f := 'O';
end;

procedure p (c: Char);
begin
  WriteLn (c, 'K')
end;

begin
  {$W-}
  p (f)
end.
