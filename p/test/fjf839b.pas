program fjf839b;

function f: Integer;
begin
  WriteLn ('failed');
  f := 42
end;

begin
  f  { WRONG }
end.
