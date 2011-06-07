program fjf569m;

const
  a: String (20) = '';

begin
  WriteLn ('failed');
  Halt;
  Str (42, a)  { WARN }
end.
