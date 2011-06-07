program fjf503;

var
  c : Char = 'a';

begin
  if c < 100  { WRONG }
    then WriteLn ('failed')
    else WriteLn ('failed very much')
end.
