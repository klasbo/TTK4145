// Tested on a virtual machine with one core
// gcc -std=gnu99 -Wall -g -lpthread -ohelloworld_c helloworld_c.c

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

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
        // usleep(20);          // May just be necessary for my single-core VM
                                // Just to show that actual counting happens
                                // (ie. it isn't optimized away)
        printf("%i\n", i);
    }

    
    pthread_join(adder_thr, NULL);
    printf("Done: %i\n", i);
    return 0;
    
}