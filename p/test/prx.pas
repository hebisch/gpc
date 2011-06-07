program Prx;
var
a5: array[1..5] of char := '01960';
b5: array[1..5] of char := '01959';
a4: array[1..4] of char := '1960';
b4: array[1..4] of char := '1959';
cs: string(4) := '1960';
bs: string(4) := '1959';
begin
  if a5 <= '01959' then writeln('failed! array 5 - costant');
  if a5 <= b5 then writeln('failed! array 5');
  if a4 <= '1959' then writeln('failed! array 4 - costant');
  {above the falling test?}
  if a4 <= b4 then writeln('failed! array 4');
  if cs <= bs then writeln('failed! string');
  writeln ('OK')
end.
