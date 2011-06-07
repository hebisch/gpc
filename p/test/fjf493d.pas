{$extended-pascal}

program fjf493d (Output);

var f: Text;

begin
  with Binding (f) do WriteLn (Bound)  { WRONG (EP) }
end.
