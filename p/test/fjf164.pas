program fjf164;

{ FLAG -Werror }

uses fjf164a, fjf164b;

var
  v1 : p1;
  v2 : p2;

begin
  v1 := v2;
  if v1 = v2 then WriteLn ('OK') else WriteLn ('Failed')
end.
