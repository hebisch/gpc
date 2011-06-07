program adam3a;

var a:array[0..10] of integer;

function at(const index:integer):integer;
begin
  at:=a[index];
end;

begin
  a[3] := 42;
  if at(3) = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
