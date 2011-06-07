program fjf824f;

{$I-}
function f: Integer;
var t: Text;
begin
  Reset (t);
  f := 42
end;
{$I+}

begin
  f  { WARN }
end.
