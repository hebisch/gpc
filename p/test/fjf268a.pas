program fjf268a;

const s : string (10) = '';

begin
  writeln ('failed');
  halt;
  delete (s, 1, 1) { WARN }
end.
