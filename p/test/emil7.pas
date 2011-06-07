program P (Output);
{ FLAG -O -finline-functions -Wno-uninitialized }
{ -g not added above because not supported on all platforms;
  where it is, it is usually part of the normal flags, anyway }

var
  A: Integer;

procedure S;
var
  B: 0 .. 1;
begin
  A := B
end;

begin
  S;
  WriteLn ('OK')
end.
