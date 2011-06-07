program fjf850f;

function foo = a: Integer; forward;

function foo ();  { WRONG }
begin
  a := 42
end;

begin
  if foo = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
