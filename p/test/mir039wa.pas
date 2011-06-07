program mir039wa;
{BlockWrite call with 4th parm integer out of bounds}
uses GPC;
type range = 12..42;
var  k : Integer;
     myF : File;
     actuallyWritten : range;
     Buf, Buf2 : packed array [1..10] of Char;

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
   BlockWrite (myF, Buf, SizeOf (Buf), actuallyWritten { Buf is smaller than range of actW });
end.
