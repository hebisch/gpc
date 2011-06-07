{ Simplified version of bug found by hanoi.pas with GPC based on
  gcc-3.1.1 with `-O3', caused by function inlining and tail
  recursion elimination. }

program fjf709;

procedure p (n: Integer);
begin
  WriteLn (n);
  if n = 1 then
    begin
      p (2);
      p (n + 3)
    end
end;

begin
  p (1)
end.
