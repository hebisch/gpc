{ The correct behaviour is that `pow' has higher precedence than `-'
  (even unary `-') which GPC does.
  <200109090620.f896KUr28818@mail.bcpl.net> }

program powTest(input, output);

begin

   writeln(-2 pow 0);            { should be 1 }
   writeln(-2 pow 1);
   writeln(-2 pow 2); writeln;   { should be 4 }

   writeln(-1 pow 0);            { should be 1 }
   writeln(-1 pow 1);
   writeln(-1 pow 2); writeln;   { should be 1 }

   writeln(1 pow 0);
   writeln(1 pow 1);
   writeln(1 pow 2); writeln;

   writeln(2 pow 0);
   writeln(2 pow 1);
   writeln(2 pow 2); writeln;
end.
