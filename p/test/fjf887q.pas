program fjf887q;

var
  i: 10 .. 20;
  j: 1 .. 5;

begin
  i := j  { WRONG, compile time error since it's wrong,
            independently of the actual value of j }
end.
