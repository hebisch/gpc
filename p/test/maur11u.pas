unit maur11u;

interface

type
   Vector3 = record
     x, y, z: Real;
   end;

operator + (u, v: Vector3) w: Vector3;

implementation

operator + (u, v: Vector3) w: Vector3;
begin
   w.x := u.x + v.x;
   w.y := u.y + v.y;
   w.z := u.z + v.z;
end;

end.
