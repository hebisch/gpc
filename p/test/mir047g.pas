program mir047g;
{testing [.$R[+-].] option(s)}
{by default range-checking is on}
uses GPC;

type Foo = 'c'..'f';
var a : record fill: Char; a: array [Foo] of Char; end;
    k : Char;
    Where : (RangeOff, RangeOn, AtEnd);

procedure TrapError;
begin
  if Where <> RangeOn then
    WriteLn ('failed')
  else
    begin
      WriteLn ('OK');
      Halt (0) {!}
    end
end;

begin
   {$R-}
   k := Pred (Low (Foo));
   Where := RangeOff;
   a.a[k] := 'b';
   {$R+}
   AtExit(TrapError);
   k := Succ (High (Foo));
   Where := RangeOn;
   a.a[k] := 'n';
   {$R-}
   k := '@';
   Where := RangeOff;
   a.a[k] := 'f';
   {$R+}
   Where := AtEnd;
end.
