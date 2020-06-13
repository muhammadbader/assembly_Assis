#include <stdio.h>

int add_print(int a, int b) {
  int c = a + b;

  printf("%d + %d = %d\n", a, b, c);

  return c;
}
