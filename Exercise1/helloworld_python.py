# Python 3.3.3 and 2.7.6
# python helloworld_python.py

from threading import Thread

i = 0

def someThreadFunction():
    print("Hello from a thread!")

# Potentially useful thing:
#   In Python you "import" a global variable, instead of "export"ing it when you declare it
#   (This is probably an effort to make you feel bad about typing the word "global")
    global i


def main():
    someThread = Thread(target = someThreadFunction, args = (),)
    someThread.start()
    
    someThread.join()
    print("Hello from main!")


main()