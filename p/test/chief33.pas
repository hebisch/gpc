program chief33;

type
myint  = integer attribute (Size = 32);
myword = cardinal attribute (Size = 32);

var
f : file;
x : array [0..2] of char;
j : myint;
k : myword;
l : longint;
begin
 assign (f, 'chief33.dat');
 x[0] := 'f'; x[1] := 'o'; x[2] := 'o';
 rewrite (f, 1);
 blockwrite (f, x, sizeof (x), j);
 blockwrite (f, x, sizeof (x), k);
 blockwrite (f, x, sizeof (x), l);
 close (f);
 WriteLn ('OK')
end.
