{ @@ Work-around for a problem with COFF debug info. }
{$ifdef __GO32__}
{$local W-} {$disable-debug-info} {$endlocal}
{$endif}

program mod15e;
const x = 'Dummy';
procedure p1;
 import e1 in 'mod15m.pas';
begin
 x := 1;
end;
procedure p2;
 import e1 in 'mod15m.pas';
begin
 f(1)
end;
begin
 p1;
 p2
end
.
