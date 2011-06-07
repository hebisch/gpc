program TestCast;
type
 BytePtr = ^Byte;
 IntPtr = ^Integer;
var
 theBytePtr : BytePtr;
 theIntPtr: IntPtr;
begin
 theBytePtr := nil;
 theIntPtr:= nil;
 BytePtr( theIntPtr) := theBytePtr;  { WARN }
end.
