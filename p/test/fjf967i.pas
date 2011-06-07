program fjf967i;

import fjf967n;

var
  OK: Boolean;
  i, j: Integer;
  a: t = aa;

begin
  OK := True;
  if (a.i <> 4) or (a.c <> 3) or (a.q <> 2) then
    begin
      WriteLn ('failed 1');
      OK := False
    end;
  for i := 1 to 200 do
    begin
      case i of
        1, 4 .. 177: j := 5;
        182: j := 4;
        else j := 2
      end;
      if a.x[i] <> j then
        begin
          WriteLn ('failed 2 ', i, ' ', a.x[i], ' ', j);
          OK := False
        end
    end;
  if OK then WriteLn ('OK') else WriteLn ('failed')
end.
