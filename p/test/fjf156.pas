program fjf156;

{$x+}

var b:string(42);
    c,d:CString;
    e,f:array[0..42] of char;

begin
  e:='O'#0;
  b:=CString2String(e);
  c:=NewCString(b);
  d:=CStringCopyString(f,'K');
  WriteLn(c,d);
  Dispose(c)
end.
