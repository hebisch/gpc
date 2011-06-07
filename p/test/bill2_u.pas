unit TrunkUti;
interface

type wrkstring=string[255];

function  BinToDec(Binary: string)   : LongInt;
function  DecToBin(DecInput: string) : wrkstring;

implementation

function BinToDec(Binary: string) : LongInt;
begin
  BinToDec:=0;
end;

function DecToBin(DecInput: string) : wrkstring;
var
   DecNum : Integer;

begin
  ReadStr(DecInput,DecNum);
  DecToBin:= '101010';
end;
end.
