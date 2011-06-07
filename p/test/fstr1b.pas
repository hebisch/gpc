program fstr1b(output);
type sat = packed array [1..16] of 'K'..'O' value [otherwise 'O'];
var sa : sat;
begin
  writeln(sa) { WRONG }
end
.

