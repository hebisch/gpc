{ out of range shift counts. IA32 (at least) seems to ignore those
  shifts (case b) completely, not good }

program fjf221;
var a : integer = 1;
    b : cardinal = $80000000;
    c : integer = 32;
begin
  if (((a shl c) and $ffffffff) = 0) and (b shr c = 0) then
    WriteLn ('OK')
  else
    WriteLn ('Failed: ', ((a shl c) and $ffffffff), ', ', b shr c)
end.
