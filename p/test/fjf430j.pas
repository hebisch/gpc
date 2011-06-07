program fjf430j;

const
  b : Integer = 42;

var
  a : Text;

begin
  if b <> 42 then begin WriteLn ('failed 1'); Halt end;
  {$i-}
  {$local i-,i+}
  {$endlocal}
  Reset (a);
  {$I+}
  if IOResult = 0
    then WriteLn ('failed')
    else WriteLn ('OK')
end.
