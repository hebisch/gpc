program john2d;

type
   r = record
       f1 : integer;
       f2 : text;
       end;

Var
  a, b: r;

begin
  a := b; { WRONG }
  writeln ('failed' );
end.
