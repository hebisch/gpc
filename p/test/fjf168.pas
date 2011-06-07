program fjf168;
const
  s='OK';
  t:string(4)=#0'OK';
begin
  if s[1..2]=t[2..3] then
    writeln(s[1..2])
  else
    writeln('Failed: ', s[1..2], ' ', t[2..3])
end.
