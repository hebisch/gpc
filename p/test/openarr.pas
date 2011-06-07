Program OpenArr;


Var
  OK: array [ 1..13 ] of Char value 'OK, isn''t it?';


Procedure WriteArray ( A: array of Char; Count: Integer );

Var
  i: Integer;

begin { WriteArray }
  i:= 0;
  while i < Count do
    begin
      write ( A [ i ] );
      inc ( i );
    end { while };
  writeln;
end { WriteArray };


begin
  WriteArray ( OK, 2 );
end.
