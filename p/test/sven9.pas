program Sort_Test;

{ demo for using of the qsort function from gpc }
{ sven@rufus.central.de }


type
  TestType = Byte;    { works with Real, ShortInt, Integer, LongInt }
                      { crashs with Byte }
  StrType  = String(8);
  FuncType = ^function: Integer;


function CompNum(var e1, e2: TestType):Integer;
var
  r : Real;
begin
  r       := Integer ( e1 ) - Integer ( e2 );
  CompNum := Round(r);
end;


function CompString(var e1, e2: StrType):Integer;
begin
  if e1 = e2 then
    CompString := 0
  else if e1 > e2 then
    CompString := 1
  else
    CompString := -1;
end;


procedure qsort(var base; numelem, size : Integer; cmp: Pointer); external name 'qsort';


var
{
  i  : Integer;
}
  ta : Array[1..5] of TestType;
  tb : Array[1..5] of StrType;


begin
  ta[1] := ord ( 'K' );
  ta[2] := 2;
  ta[3] := ord ( 'O' );
  ta[4] := 3;
  ta[5] := 255;
{
  for i := 1 to 5 do WriteLn(ta[i]);
  WriteLn;
}
  qsort(ta, 5, Sizeof(ta[1]), @CompNum);
  writeln ( chr ( ta [ 4 ] ), chr ( ta [ 3 ] ) );
{
  for i := 1 to 5 do WriteLn(ta[i]);
  WriteLn;

  tb[1] := 'Peter';
  tb[2] := 'Paul';
  tb[3] := 'Mary';
  tb[4] := 'Sven';
  tb[5] := 'Adam';

  qsort(tb, 5, Sizeof(tb[1]), @CompString);

  for i := 1 to 5 do WriteLn(tb[i]);
  WriteLn;
}
end.
