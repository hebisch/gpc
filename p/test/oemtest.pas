program OEMTest;

uses DosUnix;

var
  c : Char;

begin
  for c := #0 to #$7f do
    begin
      if OEM2Latin1 (c) <> c then
        begin
          WriteLn ('OEM2Latin1 ASCII failed: ', Ord (c));
          Halt
        end;
      if Latin12OEM (c) <> c then
        begin
          WriteLn ('Latin12OEM ASCII failed: ', Ord (c));
          Halt
        end
    end;
  for c := Low (c) to High (c) do
    begin
      { Note: some characters are missing in one of the charsets, and
        are mapped to some lower ASCII characters. Some OEM graphics
        characters are mapped to a single Latin1 character. Accept
        this. }
      if not (OEM2Latin1 (Latin12OEM (c)) in [#0 .. #$7f, c]) then
        begin
          WriteLn ('OEM2Latin1 o Latin12OEM failed: ', Ord (c));
          Halt
        end;
      if not (Latin12OEM (OEM2Latin1 (c)) in [#0 .. #$7f, #$dd, #$ee, c]) then
        begin
          WriteLn ('Latin12OEM o OEM2Latin1 failed: ', Ord (c));
          Halt
        end
    end;
  if OEM2Latin1 (#132) <> #228 then
    begin
      WriteLn ('OEM2Latin1 ä failed');
      Halt
    end;
  if Latin12OEM (#228) <> #132 then
    begin
      WriteLn ('Latin12OEM ä failed');
      Halt
    end;
  WriteLn ('OK')
end.
