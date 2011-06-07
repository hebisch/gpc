Program goto2;

Label
  42;

Var
  x: Char;

begin
  x:= 'f';
  42: write ( x );
  if x = 'a' then
    writeln ( 'iled' )
  else
    begin
      x:= 'a';
      goto 0;  { WRONG }
    end { else };
end.
