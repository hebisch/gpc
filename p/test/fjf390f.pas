{$truncate-strings}

program fjf390f;

var
  a: array [1 .. 2] of Char = {$local W-} 'OKx';

begin {$endlocal}
  WriteLn (a)
end.
