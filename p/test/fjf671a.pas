program fjf671a;

var
  foo: Text;

{$W-}

begin
  WriteLn ('failed ', foo._p_file_[1])  { WRONG }
end.
