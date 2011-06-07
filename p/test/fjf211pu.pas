unit fjf211pu;
interface
var
  a: record
       x: Integer;
     case (foo,bar,baz) of
       foo: (y: Integer)
     end;
implementation
end.
