program fjf668b;

var
  a: Cardinal = 2;

begin
  if a < Integer (0) { WARN } then WriteLn ('failed 1') else WriteLn ('failed 2')
end.
