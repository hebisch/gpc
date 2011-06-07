program subrs;
const n:1..16=6; {"subrange bounds are not of the same type"}
                 {The same with "var ...=...", ok with "var ... value ..."}
begin
  if n = 6 then
    writeln ( 'OK' );
end.
