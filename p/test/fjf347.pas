program fjf347;

var
  a : Integer = - 1;
  b : Cardinal = 1;
  s : String (100);

begin
  WriteStr (s, a * b);
  if s = '-1'
    then WriteLn ('OK')
    else WriteLn ('failed: ', s)
end.
