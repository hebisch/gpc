program mod14(Output);
{ FLAG -Wno-warnings }
import mod14u;
procedure p0; external name '_p__M6_Mod14v_S0_Pf';
procedure p1; external name '_p__M6_Mod14v_S1_myob1_Pb';
procedure p2; external name '_p__M6_Mod14v_S2_myob1_P';
procedure p3; external name '_p__M6_Mod14v_S3_myob1_Q';
function f5 (u, v: integer): integer;
         external name '_p__M6_Mod14v_S5_Foo_op_Integer_Integer';
function f6 (u: integer; v: integer): integer;
         external name '_p__M6_Mod14v_S6_Foo_op_Myob1_Integer';
var
v7: integer; external name '_p__M6_Mod14v_S7_Ob1a';
v8: integer; external name '_p__M6_Mod14v_S8_Ob1b';
v9: integer; external name '_p__M6_Mod14v_S9_Ob1c';
v10: integer; external name '_p__M6_Mod14v_S10_Va';
v11: integer; external name '_p__M6_Mod14v_S11_Vb';
v12: integer; external name '_p__M6_Mod14v_S12_Vc';

procedure p14; external name '_p__M6_Mod14v_S14_myob2_R';
procedure p15; external name '_p__M6_Mod14v_S15_myob2_Q';
procedure p16; external name '_p__M6_Mod14v_S16_myob2_P';
procedure p17; external name '_p__M6_Mod14v_S17_myob2_S';

procedure p19; external name '_p__M6_Mod14v_S19_myob3_P0';
procedure p20; external name '_p__M6_Mod14v_S20_myob3_P';
procedure p21; external name '_p__M6_Mod14v_S21_myob3_Q';
procedure p22; external name '_p__M6_Mod14v_S22_myob3_R';
procedure p23; external name '_p__M6_Mod14v_S23_myob3_S';

function f25 (u, v: integer): integer;
         external name '_p__M6_Mod14v_S25_Foo_op_Myob2_Myob3';

procedure p26 (function f(u, v: integer): integer);
         external name '_p__M6_Mod14v_S26_Take';

begin
p26(f25);
p26(f6);
p26(f5);
p23;
p22;
p21;
p20;
p19;
p17;
p16;
p15;
p14;
p3;
p2;
p1;
p0;
v10 := 5;
v11 := f5 (v7, v10);
v12 := f5 (v8, v11);
v10 := f5 (v9, 7);
if (v10 = 7) and (v12 = 5) then
  writeln('OK')
else
  writeln('failed')
end
.
