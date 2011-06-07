program fjf201h;
{$w-}
type t=^byte;
procedure p(const x:t);
begin
  WriteLn('Failed')
end;
var a:^integer;
begin
  p(a) { WRONG }
end.
