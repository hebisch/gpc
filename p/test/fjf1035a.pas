program fjf1035a;

function f: Integer;
begin
  f := 42
end;

var
  a: procedure = f;  { WRONG }

begin
end.
