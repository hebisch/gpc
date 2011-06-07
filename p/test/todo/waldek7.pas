program patest;
type smi = Integer attribute(Size = 27);
var a : packed array[0..128] of smi;
    i : Integer;
procedure prai(j: Integer);
begin
  if a[j] = 65011712 then WriteLn ('OK') else WriteLn ('failed ', a[j])
end;
begin
  for i := 0 to 128 do a[i] := 0;
  a[1] := 65011712; {1024*1024*62}
{  writeln('Sizeof(a) = ', Sizeof(a), ', a[1] = ', a[1]); }
  prai(1)
end
.
