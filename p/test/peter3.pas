{$x+}
program testpas8;

   type
     U8 = Cardinal attribute ( size = 8);
     U8Ptr = ^U8;
     CSPtr = U8Ptr;

   var
     c: CSPtr;
     t: array [1 .. 2] of U8 = (42, 17);

begin
   c := @t[1];
   Inc(CSPtr(c));
   if c^ = 17 then WriteLn ('OK') else WriteLn ('failed')
end.
