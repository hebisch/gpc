{$extended-pascal}
program gale9b (output);
type t = packed array[1..4] of char;
const
  c = t[1 : 'F'; 2: 'A'; 3 : 'I'; 4 : 'L'];

var
  y : type of c;   {WRONG} {c is neither a variable-identifier or a parameter-identifier}

begin
writeln(c);
end.

