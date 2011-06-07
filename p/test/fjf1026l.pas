{$extended-pascal}

program fjf1026l (Output);

var
  Called: Boolean value False;

function f: Integer;
begin
  if Called then WriteLn ('failed');
  Called := True;
  f := 1
end;

var
  a: record a, b: Integer end value [a, b: f];

begin
  if (a.a = 1) and (a.b = 1) then WriteLn ('OK') else WriteLn ('failed')
end.
