Program Quatsch;

{$ifdef CMULB }

The error message about `failed' below must be
reported in line 11 { instead of 15 }.

{$endif }

begin
  failed;  { WRONG }  { The problem is solved. :}
end.
