Program fjf37b;

Var
  x: packed record
    a, b: ShortInt;
  end { x };
  y: Pointer;

begin
  y:= @x.a;  { WRONG }
  writeln ( 'failed' );
end.
