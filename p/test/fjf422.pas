{ FLAG -Werror }

program fjf422;

var
  a: array [1 .. 1] of Char = ('O');
  b: array [1 .. 1] of Char = (('O'));
  c: array [1 .. 1] of String (1) = ('K');
  d: array [1 .. 1] of String (3) = ((((('K')))));
  e: Integer = (1);

begin
  if (((((((a)) = (((b))))) and ((a [((1))] = (b [(e)]))) and ((((c [e] = (d [(1)])))))))) then
    WriteLn (a, ((c [((e))])))
  else
    WriteLn ('failed ', a [1], b [1], c [1], d [1])
end.
