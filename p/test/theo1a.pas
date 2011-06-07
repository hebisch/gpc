Program Test(Input, Output);

Type
  Str10 = String(10);
  LetterType = (AA, BB, CC, DD);
  MyRec = record
    LetterName:   Array[LetterType] of Str10;
  end;

procedure SetIt(var aStr1: String; const aStr2: String);
begin
  aStr1:=aStr2;
end;

var
  ThisLetter: LetterType;
  ThisRec: MyRec;

begin
  for ThisLetter:=AA to DD do
    SetIt(ThisRec.LetterName[ThisLetter], Chr(Ord(ThisLetter)+Ord('A')));
  for ThisLetter:=AA to DD do
    WriteLn(ThisRec.LetterName[ThisLetter]);
  for ThisLetter:=AA to DD do
    ThisRec.LetterName[ThisLetter]:=Chr(Ord(ThisLetter)+Ord('A'));
  for ThisLetter:=AA to DD do
    WriteLn(ThisRec.LetterName[ThisLetter]);
end.
