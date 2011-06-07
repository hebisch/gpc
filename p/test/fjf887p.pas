program fjf887p;

var
  i: 10 .. 20;
  j: 1 .. 5;

begin
  j := i  { WRONG, compile time error since it's wrong,
            independently of the actual value of i }
end.
