Program ModType;

Var
  i: 3..9;

begin
  for i:= 4 to 5 do
    case i mod 4 of
      0: write ( 'O' );
      1: write ( 'K' );
    end { case };
  writeln;
end.
