Program FileHandle;

uses GPC;

Procedure CWrite (Handle : Integer; const Buffer; Size : SizeType); external name 'write';

const
  OK : array [1 .. 3] of Char = 'OK' + NewLine;

begin
  CWrite (FileHandle (Output), OK, Sizeof (OK))
end.
