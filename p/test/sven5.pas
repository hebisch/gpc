program longtest;

var
  R : LongReal;
  O : Real;
  SR, SO: String ( 30 );

begin
  R := 3.0;
  O := R;
  WriteStr ( SR, R );  { was: `Real ( R )', but that's not correct, Frank, 20030317 }
  WriteStr ( SO, O );
  if SR = SO then
    writeln ( 'OK' )
  else
    begin
      writeln ( SR );
      writeln ( SO );
    end { else };
end.
