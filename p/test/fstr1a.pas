program fstr1a;
type sat = packed array [1..16] of 'K'..'O';
var sa : sat;
begin
  sa := 'KKK' { WRONG }
end
.

