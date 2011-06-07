program mir047h;
{testing [.$R[+-].] option(s)}
{ FLAG --no-range-checking }
{by default range-checking is on}
uses GPC;

type Foo = 'c'..'f';
var a : record fill: Char; a: array [Foo] of Char; end;
    k : Char;
    Where : (RangeOff, RangeOn, AtEnd);

label 3;

procedure TrapError;
begin
  if Where <> RangeOn then
    WriteLn ('failed')
  else
    begin
      Write ('O');
      goto 3
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
3:
   k := '@';
   Where := RangeOff;
   a.a[k] := 'f';
   {$R+}
   Where := AtEnd;
   WriteLn ('K');
end.
