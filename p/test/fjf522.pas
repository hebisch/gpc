program fjf522;

uses GPC;

var s: TString;

begin
  s := StrSignal (127);
  s := StrSignal (255);
  WriteLn ('OK')
end.
