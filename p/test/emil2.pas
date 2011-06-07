program Emil2 (Input, Output);

uses GPC;

var
  t: Text;
  CharsRead: Integer = 0;
  s: String (10) = '';

const
  CharsToRead = 'OK' + NewLine + 'X';

function ReadFunc (var PrivateData; var Buffer; Size: SizeType): SizeType;
begin
  if CharsRead < Length (CharsToRead) then
    begin
      Inc (CharsRead);
      Char (Buffer) := CharsToRead[CharsRead];
      ReadFunc := 1
    end
  else
    ReadFunc := 0
end;

begin
  AssignTFDD (t, nil, nil, nil, ReadFunc, nil, nil, nil, nil, nil);
  Reset (t);
  while not EOLn (t) do
    begin
      s := s + t^;
      Get (t)
    end;
  Get (t);
  if CharsRead = 3 then
    WriteLn (s)
  else
    WriteLn ('failed ', CharsRead)
end.
