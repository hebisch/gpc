Program fjf529(Output);

Type
  LetterType = (AA, BB, CC, DD);

var
  ThisLetter: LetterType;

begin
  ThisLetter := bb;
  WriteLn ('failed ', ThisLetter < 5)  { WRONG }
end.
