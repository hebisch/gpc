program fjf3;

type
  ByteSet=set of Byte;

var
  m:ByteSet value [1..3,5,8]; {"const ... = ..." gives the same result}
  k:Integer; {or k:Byte - the same}
  okay: Boolean;

{ Fixed: Set variables could not be initialized. }

begin
  okay:= true;
  for k:=0 to $ff do
    if ( k in m ) <> ( ( k = 1 ) or ( k = 2 ) or ( k = 3 )
                       or ( k = 5 ) or ( k = 8 ) ) then
      okay:= false;
  if okay then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
