program drf1;

type x (n : Integer) = Integer value n;

var y : x (1);

begin
  if y = 1
    then WriteLn ('OK')
    else WriteLn ('failed ', y)
end.
