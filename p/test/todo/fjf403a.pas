{ FLAG -O3 -Wall }

program fjf403a;

procedure foo;
var x : String (100);
begin
  WriteLn ('failed ', x)  { WARN: x uninitialized }
end;

begin
  foo
end.
