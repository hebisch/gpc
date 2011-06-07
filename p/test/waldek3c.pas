{ FLAG --extended-pascal }

program waldek3c (Output);
var i,j:integer;
begin
        j := 0;
        for i:=1to 5 do j:=j+1;  { WRONG }
        WriteLn ('failed')
end.
