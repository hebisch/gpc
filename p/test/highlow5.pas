Program HighLow5;

Var
  Cmulb: array [ 'K'..'O' ] of Byte;

Procedure Bar ( foo: array [ x..y: Char ] of Byte );

begin { Bar }
  writeln ( high ( foo ), low ( foo ) );
end { Bar };

begin
  Bar ( Cmulb );
end.
