program russ3d;

uses russ3v;

type
  Line = string ( cap );

begin
  if High (Line) = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
