program fjf673;

var
  foo: Integer; attribute (blah);  { WARN }

begin
  foo := 0;
  WriteLn ('failed')
end.
