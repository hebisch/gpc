program ParserDemo (Input, Output);

{...}
procedure foo;  { @@ fjf479.pas with `i!' }

label 99;
{...}

procedure Expect (ch: Char);
begin
{...}
      goto 99
{...}
end;

{...}

begin
{...}
  while not EOLn do
    begin
{...}
      99: ReadLn  { WRONG }
    end
end;begin foo  { @@ fjf479.pas }
end.
