{ GPC demo program for the FormatTime function.

  Copyright (C) 2000-2006 Free Software Foundation, Inc.

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

program FormatTimeDemo;

uses GPC;

const
  TestFormat =
    'Some examples of formatting the current date and time using `FormatTime''.%n%n' +
    '(Note: Some of the formats are locale-dependent, so you might have to%n' +
    'set $LANG or $LC_TIME if you don''t get the right results for your country.)%n%n' +
    'Default date/time format:     %c%n' +
    'Default date format:          %x%n' +
    'Default time format:          %X%n' +
    'Alternative date/time format: %Ec%n' +
    'Alternative date format:      %Ex%n' +
    'Alternative time format:      %EX%n' +
    'Date, time (ISO format):      %F %T%n' +
    'Date, time (American format): %D %I:%M:%S %p%n' +
    'Date (German format):         %^/2a %-e.%-m.%Y%n' +
    'Day of year:                  %j%n' +
    'Weekday:                      %A (short: %a)%n' +
    'Month:                        %B (short: %b)%n' +
    'ISO week:                     %V/%G%n' +
    '1/100 seconds:                %2Q%n' +
    'Unix time:                    %s.%Q%n' +
    'Time zone (symbolic):         %Z%n' +
    'Time zone (numeric):          %z%n' +
    'RFC 822 timestamp:            %a, %d %b %Y %T %z%n';

var
  CurrentTime: TimeStamp;

begin
  GetTimeStamp (CurrentTime);
  WriteLn (FormatTime (CurrentTime, TestFormat))
end.
