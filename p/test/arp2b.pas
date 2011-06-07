program p (output);
{gpc --extended-pascal p.pas}
type tfInt = file [1..100] of integer;
var   f : tfInt;   i : integer;
procedure see(var f:tfInt);
begin
   reset(f);
   while not eof (f) do begin
      write(f^:3);
      get(f)
   end;
   writeln
end;

begin
   rewrite (f);
   for i := 1 to 10 do write(f, i);
   see( f );
   seekupdate(f, 5);
   f^ := 0;
   write(f, 50);
   writeln;
   writeln('seekupdate(f, 5); f^ := 0; write(f, 50)');
   writeln('position(f) (should be 6) = ', position(f):0);
   writeln('lastposition(f) (should be 10) = ', lastposition(f):0);
   write  ('f is   ');
   see( f );
   writeln('must be  1  2  3  4 50  6  7  8  9 10');
end.
