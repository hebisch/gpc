{ FLAG -O3 -Wall }

program fjf403b;

procedure foo;
var x : String (100);
begin
end;  { WARN: x unused }

begin
  foo;
  WriteLn ('failed')
end.
