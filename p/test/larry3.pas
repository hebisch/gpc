Program Larry3;

{$borland-pascal }

Const
  ooo = 'ooO';
  OK = 'xxx' + ooo + 'Kkk';

Var
  S: String;

begin
  S:= OK;
  writeln ( S [ 6 ], S [ 7 ] );  { BP has no subarray access }
end.
