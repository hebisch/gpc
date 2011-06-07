program fsc35;
{actual schema discriminant (range) write}
uses GPC;
 type subrange (i,j:Integer) = i..j;
var   s : ^subrange;
   i,j,k        : Integer;
procedure ExpectError;
begin
  if ExitCode = 0 then
    WriteLn ('failed')
  else
    begin
      WriteLn ('OK');
      Halt (0) {!}
    end
end;

begin
   AtExit(ExpectError);
   i:=10;
   j:=100;
   new (s,i,j);
   k:=5;
   {k is out of bounds...}
   s^:=k;
end.
