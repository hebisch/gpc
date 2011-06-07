{ Qualified identifiers }

Program Chief18;

uses
  one in 'chief18u.pas',
  two in 'chief18v.pas';

begin
  if positive ( 42 ) and neutral ( 0 ) and negative ( -137 ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed' )
end.
