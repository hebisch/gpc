program sets17a(output);
type enu = (en1, en2, en3, en4);
     subr = 0..6;
var ok : boolean;
    bv : boolean;
    sb1, sb2 : packed set of boolean;
    ev : enu;
    se1, se2 : packed set of enu;
    rv : subr;
    sr1, sr2 : packed set of subr;

begin
  ok := true;
{ boolean }
  bv := false;
  sb1 := [bv];
  if sb1 <> [false] then 
    ok := false;
  sb1 := [true];
  sb2 := sb1 + [bv];
  if sb2 <> [false..true] then
    ok := false;

{ enum }
  ev := en2;
  se1 := [ev];
  if se1 <> [en2] then
    ok := false;
  se1 := [en3];
  se2 := se1 + [ev];
  if se2 <> [en2,en3] then
    ok := false;

{ subrange }
  rv := 2;
  sr1 := [rv];
  if sr1 <> [2] then
    ok := false;
  sr1 := sr1 - [3];
  if sr1 <> [2] then
    ok := false;
  sr1 := sr1 * [2..3];
  if sr1 <= [3] then
    ok := false;
  sr1 := [3];
  if sr1 = [2..3] then
    ok := false;
  sr2 := sr1 + [rv];
  if sr2 <> ([2] + [3]) then
    ok := false;
  if (sr2 + ([4..6]*[3,5])) <> ([2..5] - [4]) then
    ok := false;

  if ok then
    writeln('OK')
end
.  
