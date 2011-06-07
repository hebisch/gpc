{$standard-pascal}
program tststr1d;
var s1: packed array[ 1..1] of char;
    s2: packed array[ 1..2] of char; 
begin
   s1[1]:= '?';
   s2 := s1 { WRONG }
end.

