program t2(input,output);

uses esven1u;

begin
  GetTimeStamp ( t );
  if date(t) <> '' then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
