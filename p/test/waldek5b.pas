program Waldek5b;

Type
  R = record
  C: Char;
  i: Integer;
  end { R };

  Var
  A: array [ 1..2 ] of R value ( 2:( i: 7 ; C: 'K' ),
                                 1:( 'O'; 42 ) );

begin
        writeln ( A [ 1 ].C, A [ 2 ].C );
end.
