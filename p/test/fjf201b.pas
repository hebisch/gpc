program fjf201b;
{$w-}
var a:^integer;b:^byte;
begin
  a:=b; { WRONG }
  WriteLn('Failed')
end.
