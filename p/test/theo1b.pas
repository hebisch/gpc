Program Test2(Output);

Type
  Str10 = String(10);
  LetterType = (AA, BB, CC, DD);
  MyRec = record
    LetterName:   Array[LetterType] of Str10;
  end;

var
  ThisLetter: LetterType;
  ThisRec: MyRec;

begin
  for ThisLetter:=AA to DD do
    writeln (ThisRec.LetterName[ThisLetter].Capacity);
end.
