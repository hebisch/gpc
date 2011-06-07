program fjf570d (Output);

const
  i: Integer = 0;

begin
  {$extended-pascal}
  i := 2;  { WRONG }
  WriteLn ('failed')
end.
