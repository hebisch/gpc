unit martin6u;

interface

Const    CstrSize = 254;

   type

     StatRecord = array[1..20] of Integer;
     CstrIndex = 1..CstrSize+1;
     Cstring0 = packed array [CstrIndex] of Char;

   function Cstr(protected s: String): Cstring0;

   function rmdir(protected Path: Cstring0): Integer; external name 'rmdir';

   function sys_stat(protected Path: Cstring0; var Buf: StatRecord): Integer;
   attribute (name = 'xstat');

implementation

   function Cstr;

     var I, U: CstrIndex; Result: Cstring0;

     begin
       U := length(s);
       if U > CstrSize then U := CstrSize;
       for I := 1 to U do
         Result[I] := s[I];
       Result[U+1] := chr(0);
       Cstr := Result;
     end { Cstr };

   function sys_stat(protected Path: Cstring0; var Buf: StatRecord): Integer;
   begin
     sys_stat := 0
   end;

end.
