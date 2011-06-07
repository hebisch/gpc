{$standard-pascal}
program tststr1a( Output);
var s: packed array[ 1..1] of char;
begin
   s[1]:= '?';
   writeln( s) { WRONG }
end.

