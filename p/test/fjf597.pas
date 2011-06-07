{ GPC crashed with `-g' in TextEdit: TAbstractTextData.GetColorPtr

  This test didn't reproduce the crash per se, but (before the fix)
  it could be used to show with debug_tree() some obstack problems
  (in finish_function() at the end of function f). }
{$W-}
program fjf597;

type
  t1 (d: Integer) = array [1 .. d] of Integer;
  p1 = ^t1;
  t2 = array [0 .. 1, 0 .. 1] of record a: p1 end;
  p2 = ^t2;

procedure p (x: p2);
var i:Integer;
begin
  with x^[i, i] do
end;

function f: p1;
begin
  f := nil {.$debug-source}
end;

begin
  WriteLn ('OK')
end.
