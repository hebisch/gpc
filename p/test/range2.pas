program range2(input,output);

import GPC;
type arange = 0..5;

var a,b : arange;
    ErrFlag : boolean;
procedure ExpectError;
begin
    if ExitCode = 0 then
        WriteLn ('failed')
    else begin
        if ErrFlag then 
            WriteLn ('OK')
        else
            WriteLn ('failed');
        Halt (0)
    end
end;

begin
    AtExit (ExpectError);
    ErrFlag := false;
    a:= 0;
    b := max(a - 1, 0);         { keep b in range }
    ErrFlag := true;
    { below b now really go out of range }
    a := b - 1;  
end
.
