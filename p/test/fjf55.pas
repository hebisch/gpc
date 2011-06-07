program fjf55;
var
 q:packed array [1..10] of boolean;
 y:^boolean;
begin
 y:=@q[3];  { WRONG }
 WriteLn ('failed')
end.
