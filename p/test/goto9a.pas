{$no-iso-goto-restrictions}
{$W-}
program goto9a(output);
label 1;
begin
  if true then
    goto 1
  else
    1: writeln('OK')
end
.
