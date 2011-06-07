PROGRAM Thamm1;

USES PktDefs in 'thamm1u.pas',
     XFrames in 'thamm1v.pas';

VAR
  p : PacketPtr;
  MyFrames : tFrames;

BEGIN
  MyFrames.init('evecut.pas');
  if MyFrames.GetNextDataPkt(p) then
    WRITELN('OK')
  else
    WRITELN('FAILED');
  MyFrames.done;
END.
