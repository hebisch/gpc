{ Backend bug }

program fjf206;
var a:longcard=$ffffffffffffffff+1; { WRONG }
begin
  WriteLn('Failed')
end.
