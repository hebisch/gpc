Module kevin5f Interface;
Export
  kevin5f = (test1);
procedure test1(addr : integer; float : real);
end. { Interface }

Module kevin5f Implementation;
procedure test1;
begin
{
        writeln(addr);
        writeln(float);
}
  if ( addr = 42 ) and ( abs ( float - 3.14 ) < 1E-15 ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', addr, ' ', float );
end;
end.
