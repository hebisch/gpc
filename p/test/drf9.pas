program drf9;

var
  a : array [1 .. 10] of Integer = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
  b : array [1 .. 5] of Integer = (11, 12, 13, 14, 15);
  c : array [1 .. 10] of Integer = (1, 11, 12, 13, 14, 15, 7, 8, 9, 10);

begin
  a [2 .. 6] := b;  { After talking with Peter, we concluded that this
                      is WRONG since the index domain of b is 1 .. 5,
                      not 2 .. 6, which is not equivalent in Pascal.
                      Furthermore, even if it was `a[1 .. 5]', it
                      would not be compatible since distinct array types
                      are not compatible in Pascal, even if they look
                      the same. (We might make an exception for array
                      slices in the future, but this might be more work
                      than it's worth.) -- Frank }
  WriteLn ('failed')
{  if a = c then WriteLn ('OK') else WriteLn ('failed') }
end.
