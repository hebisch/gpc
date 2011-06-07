program drf2a;

var p : set of Integer;  { WARN -- maybe it will be allowed later }

begin
  if SizeOf (p) = 0 then WriteLn ('failed') else WriteLn ('(OK)')
end.
