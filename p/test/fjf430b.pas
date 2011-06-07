program fjf430b;

const
  b : Integer = 42;

var
  a : Text;

begin
  {$local W typed-const}
  Inc (b);  { WARN }
  {$endlocal}
  WriteLn ('failed')
end.
