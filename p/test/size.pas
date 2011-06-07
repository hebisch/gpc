program size(input,output);

type
str = array[1..20] of char;
bigary = array[1..10000] of integer;
{huge = array[1..20000] of integer;}
color = (black, purple, violet, red, pink, green,
         blue, orange, yellow, white, none);
const
colornames:array[color] of string[10] =
('black', 'purple', 'violet', 'red', 'pink', 'green',
         'blue', 'orange', 'yellow', 'white', 'none');

var
nums :bigary;
{mnums :huge;}
paint :color;
s: string (10);

function bar( value :integer) :str;
begin
write(value:1);
bar := ' is the value';
end;

function foo :str;
begin
foo := 'this is a test';
end;

begin
writeln('Enter an integer');
read(nums[5]);
writeln(bar(nums[5]));
writeln(foo);
writeln('enter a color');
while input^=' ' do get(input);
read(s);
paint:=black;
while (paint<none) and (colornames[paint]<>s) do Inc(paint);
writeln('The next color is ',colornames[succ(paint)]);
end.
