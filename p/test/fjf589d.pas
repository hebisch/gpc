program fjf589d;

const
  TStringSize = 2048;

type
  TString    = String (TStringSize);
  TStringBuf = packed array [0 .. TStringSize] of Char;

begin
  if High (TString) = High (TStringBuf) then WriteLn ('OK') else WriteLn ('failed')
end.
