Program BPStr;

{ FLAG --borland-pascal }

Var
  S: String;

begin
  Str ( 3.14, 15, 926, S );  { WRONG }
  writeln ( 'failed' );
end.
