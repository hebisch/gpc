program fjf201f;
{$w-}
type t=^byte;
procedure p(var x:t);
begin
  WriteLn('Failed')
end;
var a:^integer;
begin
  p(a) { WRONG }
end.
