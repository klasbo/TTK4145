import  std.stdio,
        std.concurrency;

// If i is not shared, it will be thread-local
shared long i;      // hint 1: long is 64 bit

void setToZero(){
    while(true){
        i = 0;
    }
}

void setToMinusOne(){
    while(true){
        i = -1;     // hint 2: two's complement
    }
}

void verifyValue(){
    while(true){
        if(i != 0  &&  i != -1){
            writeln("Error! i is ", i);
        }
    }
}

void main(){
    spawn( &setToZero );
    spawn( &setToMinusOne );
    spawn( &verifyValue );
}
