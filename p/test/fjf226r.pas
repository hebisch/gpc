program fjf226r;

{$B-,I+}

begin
  inoutres := -1;
  if false and (filesize (output) <> 42)
    then
      begin
        inoutres := 0;
        writeln ('failed')
      end
    else
      begin
        inoutres := 0;
        writeln ('OK')
      end
end.
