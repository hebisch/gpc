Program Ken1b;
function SprintF (str : Pointer; fmt : Cstring; ... ): Cinteger ;
                  external name 'sprintf';

var l : Cinteger;
    buf : packed array [1..100] of char;
    ss : string(100);
    r1 : real value 666.0;
    r2 : real value 6.125;
    sv : packed array [1..3] of char value 'sv' #0 ;

begin
  l := SprintF (@buf, '%05d %3.0f %ld %ld %c %c %5.3f %s %s', 747, r1, 
                       MedInt(7), MedInt(111), 'a', 'x', r2, 'SS', @sv);
  ss := buf;
  SetLength(ss, l);
  if ss = '00747 666 7 111 a x 6.125 SS sv' then
    writeln('OK')
  else begin
    writeln('failed: -->', ss, '<--');
    writeln('buf: ->', buf, '<--')
  end
end.
