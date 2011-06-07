{ SP alternative character `@' for `^' }

program fjf411;

type
  PString = @String;

var
  p : PString = @'O';
  q : PString = @'K';
  r : @PString = @q;

begin
  WriteLn (p@, r@@)
end.
