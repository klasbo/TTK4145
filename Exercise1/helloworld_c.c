// gcc 4.7.2 +
// gcc -std=gnu99 -Wall -g -o helloworld_c helloworld_c.c -lpthread

#include <pthread.h>
#include <stdio.h>


// Note the return type: void*
void* someThreadFunction(){
    printf("Hello from a thread!\n")
    return NULL;
}



int main(){
    pthread_t someThreadFunction;
    pthread_create(&someThread, NULL, someThreadFunction, NULL);
    // Arguments to a thread would be passed here ---------^
    
    pthread_join(someThread, NULL);
    printf("Hello from main!"\n);
    return 0;
    
}
