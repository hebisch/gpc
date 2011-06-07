{ We could allow this, but for consistency with variable-sized types
  (and larger types with `--stack-checking'), it seems better to forbid it. }

program fjf1043 (Output);

label 1;

begin
  goto 1;  { WRONG }
  var a: Integer;
1:
end.
