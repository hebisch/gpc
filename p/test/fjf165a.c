#include <ctype.h>
#include <locale.h>

int main ()
{
  setlocale (LC_ALL, "");
  return !(toupper ((unsigned char) '�') == (unsigned char) '�');
}
