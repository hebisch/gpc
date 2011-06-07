{ Fails on the Sparc when compiled with -O2 or higher: writes only O }

{ FLAG -O3 }

program fjf329b;

type
  charset = set of char;

var
  o, k : char; attribute (volatile);
  s : charset;
  a : char;

begin
  o := '-';
  k := 'K';
  {$local W-} s := [o, 'O', k]; {$endlocal}
  for a := 'Z' downto 'A' do
    if a in s then Write (a);
  WriteLn
end.
