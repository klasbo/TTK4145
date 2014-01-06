// Go 1.2
// go run helloworld_go.go

package main

import (
    . "fmt"     // Using '.' to avoid prefixing functions with their package names
    . "runtime" //   This is probably not a good idea for large projects...
)

var i = 0

func adder() {
    for x := 0; x < 1000000; x++ {
        i++
    }
}

func main() {
    GOMAXPROCS(NumCPU())        // I guess this is a hint to what GOMAXPROCS does...
    go adder()                  // This spawns adder() as a goroutine
    for x := 0; x < 50; x++ {
        Println(i)
    }
    Println("Done:", i);
}