program fjf201a;
{$w-}
var a:^integer;b:^cardinal;
begin
  a:=b; { WRONG }
  WriteLn('Failed')
end.
