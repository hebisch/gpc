program Waldek5a;

Type
  R = record
  C: Char;
  i: Integer;
  end { R };

  Var
      A: array [ 1..2 ] of R value ( ( i: 7 ; C: 'O' ),
                                      ( 'K'; 42 ) );

begin
        writeln ( A [ 1 ].C, A [ 2 ].C );
end.
