program drf2b;

var p : set of -MaxInt .. MaxInt;  { WARN -- maybe it will be allowed later }

begin
  if SizeOf (p) = 0 then WriteLn ('failed') else WriteLn ('(OK)')
end.
