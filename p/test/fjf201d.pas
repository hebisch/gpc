program fjf201d;
{$w-}
type t=^byte;
procedure p(x:t);
begin
  WriteLn('Failed')
end;
var a:^integer;
begin
  p(a) { WRONG }
end.
