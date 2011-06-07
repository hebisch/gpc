Program Moves;

Var
  S: array [ 0..9 ] of Char = '0123456789';

begin
  Move ( S [ 0 ], S [ 2 ], 5 );
  if S <> '0101234789' then
    writeln ( 'failed (1): ', S )
  else
    begin
      MoveLeft ( S [ 7 ], S [ 6 ], 3 );
      if S <> '0101237899' then
        writeln ( 'failed (2): ', S )
      else
        begin
          MoveRight ( S [ 5 ], S [ 3 ], 4 );
          if S <> '0108989899' then
            writeln ( 'failed (3): ', S )
          else
            begin
              Move ( S [ 7 ], S [ 6 ], 2 );
              if S <> '0108988999' then
                writeln ( 'failed (4): ', S )
              else
                writeln ( 'OK' );
            end { else };
        end { else };
    end { else };
end.
