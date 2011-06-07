program maur11;

uses maur11u;

var
   a, b, c: Vector3 = (1, 2, 3);

begin
    c := a + b;
    if (c.x = 2) and (c.y = 4) and (c.z = 6) then WriteLn ('OK') else WriteLn ('failed')
end.
