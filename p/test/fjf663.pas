program fjf663;

uses GPC;

var
  f: ^Text;
  s: array [1 .. 1] of PAnyFile;

begin
  if (ParamStr (1) = '') or (ParamStr (1) = '-') then
    begin
      WriteLn ('failed: ParamStr (1) is empty');
      Halt
    end;
  repeat
    New (f);
    Reset (f^, ParamStr (1))
  until FileHandle (f^) >= 8;
  s[1] := f;
  case IOSelectRead (s, 0) of
    1:   WriteLn ('OK');
    -1:  WriteLn ('SKIPPED: IOSelectRead not supported on this system');
    else WriteLn ('failed')
  end
end.
