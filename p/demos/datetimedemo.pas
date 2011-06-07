{ GPC demo program for the Extended Pascal date/time routines.

  Copyright (C) 1999-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License as
  published by the Free Software Foundation, version 2.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; see the file COPYING. If not, write to
  the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
  Boston, MA 02111-1307, USA.

  As a special exception, if you incorporate even large parts of the
  code of this demo program into another program with substantially
  different functionality, this does not cause the other program to
  be covered by the GNU General Public License. This exception does
  not however invalidate any other reasons why it might be covered
  by the GNU General Public License. }

program DateTimeDemo;

const
  DayOfWeekName: array [0 .. 6] of String (9) =
    ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');

var
  CurrentTime: TimeStamp;

begin
  GetTimeStamp (CurrentTime);
  with CurrentTime do
    begin
      if DateValid then
        WriteLn ('The date is ', Date (CurrentTime))
      else
        WriteLn ('Could not get the date.');
      if TimeValid then
        begin
          WriteLn ('The time is ', Time (CurrentTime));
          WriteLn;
          WriteLn ('Non-standard extensions:');
          WriteLn ('Fraction of second: ', MicroSecond / 1000000 : 0 : 6);
          WriteLn ('Day of week: ', DayOfWeekName[DayOfWeek]);
          WriteLn ('Time zone (seconds east of UTC): ', TimeZone)
        end
      else
        WriteLn ('Could not get the time.')
    end;
  WriteLn;
  WriteLn ('See also formattimedemo.')
end.
