program TCS_Test3;

uses martin2v;

var
  a: t;

begin
  a.a := true;
  a.b := 0;
  if a.a then WriteLn ('OK') else WriteLn ('failed ')
end.
