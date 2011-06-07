program fjf507b;

const b: array [-2 .. 7] of Char = 'DJOKWJEHDJ';

begin
  var a: String(5) = {$local W-} b;; {$endlocal}
  WriteLn (a[3 .. 4])
end.
