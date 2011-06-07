program subrw ( output );

{$extended-pascal }

{ WRONG with ISO Pascal }

const n:1..16=6; {"subrange bounds are not of the same type"}
                 {the same with "var ...=...", ok with "var ... value ..."}
begin
  writeln ( 'failed' );
end.
