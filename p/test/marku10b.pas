program Markus10b;

Function Bar: integer; forward;

Function Bar = result: integer;
begin (* Bar *)
  result:= 2;
end (* Bar *);

begin
  if Bar = 2 then WriteLn ('OK') else WriteLn ('failed')
end.
