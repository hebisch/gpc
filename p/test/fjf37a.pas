Program fjf37a;

type
  Int13 = Integer attribute (Size = 13);
  Card7 = Cardinal attribute (Size = 7);

Var
  x: packed record
    a: Int13;
    b: Card7;
  end { x };

begin
  ReadStr ( '79 75', x.b, x.a );
  writeln ( chr ( x.b ), chr ( x.a ) );
end.
