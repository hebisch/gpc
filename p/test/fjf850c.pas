program fjf850c;

var
  a, b: Integer;

function foo = a: Integer; forward;

function foo = b: Integer;  { WRONG }
begin
  { Just to avoid errors about non-assigned result }
  a := 0;
  b := 0
end;

begin
end.
