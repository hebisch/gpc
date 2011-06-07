program fjf904k;

var
  Called: Integer = 0;

function f: Integer;
begin
  Inc (Called);
  f := 42
end;

begin
  if (CompilerAssert (True, f) = 42) and (Called = 1) then WriteLn ('OK') else WriteLn ('failed')
end.
