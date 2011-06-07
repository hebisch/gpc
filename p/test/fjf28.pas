program fjf28;
{$x+}
{$ifndef __GPC__}
{$f+}
type ptrint=integer;
{$endif}

{Write a pointer (with BP: only the offset, but this doesn't matter here)}
function wp(p:pointer): ptrint;
begin
 wp:=ptrint(p)
end;

{Test function}
function y:pointer;
begin
 y:=nil
end;

{ Fixed: Something goes wrong with RESULT_DECLs. }

type t=function:pointer;

var
 va:ptrint;
 v:t absolute va;
 vaddr,yaddr:ptrint;

begin
 v:=y;    {Let v point to y}

 vaddr:= wp(@va); {Should give the address of the variable v for reference purposes}
 yaddr:= wp(@y);  {Should give the address of the function y for reference purposes}

 {6 different ways of accessing some addresses...}
 if ( wp(v) = 0 )
    and ( wp(@v) = yaddr )
    and ( wp(@@v) = vaddr )
    and ( wp(pointer(v)) = 0 )
    and ( wp(pointer(@v)) = yaddr )
    and ( wp(pointer(@@v)) = vaddr ) then
   writeln ( 'OK' )
 else
   begin
     writeln ( 'failed:' );
     writeln ( 'v =   ', vaddr );
     writeln ( 'y =   ', yaddr );
     writeln ( 'v:    ', wp ( v ) );
     writeln ( '@v:   ', wp ( @v ) );
     writeln ( '@@v:  ', wp ( @@v ) );
     writeln ( 'pv:   ', wp ( pointer ( v ) ) );
     writeln ( 'p@v:  ', wp ( pointer ( @v ) ) );
     writeln ( 'p@@v: ', wp ( pointer ( @@v ) ) );
     writeln ( '(Sollte sein: 0, y, v, 0, y, v)' );
   end { else };

end.

{

The results with BP are (where "v" means the actual address of v, "y" that
of y, and "0" means nil):

  v,y,0,y,v,0,y,v

gpc gives (where "-" means, doesn't compile, and "?" is a seemingly arbitrary
value):

  v,0,-,v,-,?,v,-

}
