#include<stdio.h>
#include<string.h>
#include<stdlib.h>

extern void assFunc(int x, int y);
extern char c_checkValidity(int x, int y);

int main(int argc,char** argv)
{
    int BUFFER=2;
    char input[BUFFER];
    char* xy=malloc(sizeof(1));
    *xy=0;
    int x,y,num=0;
    while(fgets(input,BUFFER,stdin))
    {
        xy=realloc(xy,strlen(xy)+strlen(input)+1);
        strcat(xy,input);
        if(xy[strlen(xy)-1]=='\n')
        {
            if(num)
            {
                sscanf(xy,"%d%d",&x,&y);
                break;
            }
            num++;
        }
    }
    free(xy);
    assFunc(x,y);
}

char c_checkValidity(int x, int y)
{
    
    char c=x>=y?'1':'0';
    
    return c;
}