program test(input, output);

procedure x(procedure y(a:  integer));
   function b:  integer;
   begin
      y(2);
      b:=5;
   end;

begin
   y(1);
   write(output, 'Function b returns ');
   writeln(output, b:10);
end;

procedure z(a:  integer);
begin
   writeln(output, 'Answer is ', a:0);
end;


begin
   x(z);
end.
