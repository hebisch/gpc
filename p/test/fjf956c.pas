{$W no-cast-align}

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
 theIntPtr:= IntPtr( theBytePtr);       {testcast.pas:11: warning: cast
increases required alignment of target type}
 BytePtr( theIntPtr) := theBytePtr;
 theBytePtr:= BytePtr( theIntPtr);
 IntPtr( theBytePtr):= theIntPtr;      {testcast.pas:14: warning: cast
increases required alignment of target type}
 WriteLn ('OK')
end.
