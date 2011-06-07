Program DNull1;

Procedure O;

Var
  Null: Char = 'O';

begin { O }
  write ( Null );
end { O };

Procedure K ( Var x: Integer );

begin { K }
  if @x = Nil then
    writeln ( 'K' )
  else
    writeln ( 'failed' );
end { K };

begin
  O;
  K ( Null );
end.
