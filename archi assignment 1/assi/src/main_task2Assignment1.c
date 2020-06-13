#include <stdio.h>
#include <string.h>

#define    MAX_LEN 34            /* maximal input string size */
                    /* enough to get 32-bit string + '\n' + null terminator */
extern int convertor(char* buf);
extern void test();

int main(int argc, char** argv)
{
  while(1)
  {
    char buf[MAX_LEN ];
    fgets(buf, MAX_LEN, stdin);        /* get user input string */
    if(buf[0]=='q') break;
    convertor(buf);            /* call your assembly function */
  }
  return 0;
}