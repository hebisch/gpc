program mir039rb;
{BlockRead call with 4th parm integer out of bounds}
uses GPC;
type range = 12..42;
var  k : Integer;
     myF : File;
     actuallyRead : range;
     Buf, Buf2 : packed array [1..100] of Char;

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
   for k := Low (Buf) to High (Buf) do
     Buf [k] := '*';

   Rewrite (myF, 'dummy.dat', 1);
   BlockWrite (myF, Buf, SizeOf (Buf));
   Reset (myF, 'dummy.dat', 1);
   BlockRead (myF, Buf2, SizeOf (Buf), actuallyRead { Buf is larger than range });
end.
