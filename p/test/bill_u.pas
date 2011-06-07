unit bill_Foo;

interface

Type
  WrkString = String ( 255 );

function DecToBin ( DecInput : String ) : WrkString;

implementation

function DecToBin ( DecInput : String ) : WrkString;

{ converts a decimal string[ up to 256 ] into binary string }

var
   TempStr : WrkString;
   DecNum  : integer;
   Mask    : word;
   Pos     : byte;

begin
  TempStr := '';
  Mask    := 1 shl 5;
  ReadStr(DecInput,DecNum);
  for Pos := 1 to 6 do begin
    if (Mask and DecNum) > 0 then
      TempStr := TempStr + '1'
    else TempStr := TempStr + '0';
      Mask := Mask div 2;
  end;
  {$if 0 }
    delete(TempStr,1,1);
  {$endif }
  DecToBin := TempStr;
end;

end.
