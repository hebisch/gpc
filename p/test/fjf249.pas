program fjf249;

{ FLAG -Werror }

type t = string (2);

function o : char;
begin
  return 'O'
end;

function k : t;
begin
  return 'K'
end;

begin
  writeln (o, k)
end.
