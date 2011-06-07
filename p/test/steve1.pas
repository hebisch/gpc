program steve1(output);

uses StringUtils;

var
    Src : String (255)="abc x";
    Dest : String (255);
    i : Integer;

procedure Error (const s : String);
begin
  WriteLn ('failed ', s);
  Halt (1)
end;

begin
   i := 1;
   if not StrReadWord(Src,i,Dest) then Error ('r1');
   if i <> 4 then Error ('i1');
   if Dest <> 'abc' then Error ('d1');
   if not StrReadWord(Src,i,Dest) then Error ('r2');
   if i <> 6 then Error ('i2');
   if Dest <> 'x' then Error ('d2');
   if StrReadWord(Src,i,Dest) then Error ('r3');
   WriteLn ('OK')
end.
