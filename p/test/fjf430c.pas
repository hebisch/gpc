program fjf430c;

const
  b : Integer = 42;

var
  a : Text;

begin
  {$local W typed-const}
  {$endlocal}
  Inc (b);  { WARN }
  WriteLn ('failed')
end.
