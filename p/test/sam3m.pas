Module Sam3m;

Export
  Sam3m = ( p1 );

procedure p1(a1 : array [lo .. hi : integer ] of integer ); attribute (name = 'p1');

end;

procedure p1(a1 : array [lo .. hi : integer ] of integer );

begin { p1 }
  if ( lo = 1 ) and ( hi = 10 ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end { p1 };

end.
