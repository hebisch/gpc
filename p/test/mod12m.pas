module mod12m interface;

export
mod12m = (StrPCopy);

const
   LONGEST_STRING =  256;

type
   Any_String = String(LONGEST_STRING);

function StrPCopy (Dest : CString; Src : Any_String) : CString;

end.

module mod12m implementation;


{ function StrPCopy : CString; }
{ Doesn't compile, either }
function StrPCopy (Dest : CString; Src : Any_String) : CString;
var
   c : integer;
   p : CString;
begin
   Src:= Src + 'K';
   p := Dest;
   for c:=1 to length(Src) do
   begin
      p^ := Src[c];
      inc(ptrword(p));
   end;
   p^ := chr(0);
   StrPCopy := Dest;
end;

end.
