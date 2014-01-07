// gcc 4.7.2 +
// gcc -std=gnu99 -Wall -g -lpthread -o helloworld_c helloworld_c.c

#include <pthread.h>
#include <stdio.h>

int i = 0;

// Note the return type: void*
void* adder(){
    for(int x = 0; x < 1000000; x++){
        i++;
    }
    return NULL;
}



int main(){
    pthread_t adder_thr;
    pthread_create(&adder_thr, NULL, adder, NULL);
    for(int x = 0; x < 50; x++){
        printf("%i\n", i);
    }

    
    pthread_join(adder_thr, NULL);
    printf("Done: %i\n", i);
    return 0;
    
}