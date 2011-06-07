program Nicola4a;

type
  TString = String (2048);

procedure Routine (const Name: String);
var
  Str1, Str2, Str3, Str4, Str5, Str6: TString;
const
  StringRecordArray: array [1 .. 6] of record
    StringPointer: ^String
  end =
    ((@Str1), (@Str2), (@Str3), (@Str4), (@Str5), (@Str6));  { WRONG -- addresses not constant }

  procedure SubRoutine;
  begin
  end;

begin
end;

begin
end.
