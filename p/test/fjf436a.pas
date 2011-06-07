program fjf436a;

var
  s : String (3) = 'xx';

begin
  WriteLn ({$X+} CString (s)) {$X-}  { WARN Frank, 20030317 }
end.
