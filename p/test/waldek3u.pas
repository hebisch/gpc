{$borland-pascal}

unit waldek3u;
interface
function foo(const s : string) : integer;
implementation
function foo(const s : string) : integer;
var i,j:integer;
begin
        j := 0;
        for i:=1to 5 do j:=j+1;
        foo := j;
end;
end.
