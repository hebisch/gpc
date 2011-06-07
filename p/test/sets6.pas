Program Sets6;

Var
  foo: set of Char = [ 'O', 'K' ];

begin
  {$local W-} if foo >= [ ] then {$endlocal}
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
