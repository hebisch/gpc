program fjf781c;

const
  c: String (6) = 'OK'; attribute (const);

begin
  c := 'failed';  { WRONG }
  WriteLn (c)
end.
