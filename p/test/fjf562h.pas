program fjf562h;
var i: record a, b: Integer end;
begin
  with i do;  { WARN }
  WriteLn ('failed')
end.
