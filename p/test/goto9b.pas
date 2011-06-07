{$no-iso-goto-restrictions}
program goto9a(output);
label 1;
begin
  if true then
    goto 1 { WARN }
  else
    1: writeln('OK')
end
.
