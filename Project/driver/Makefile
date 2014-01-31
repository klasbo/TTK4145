# Compiler flags go here.
CFLAGS = -std=c99 -g -Wall -O2 -I . -MMD

# Linker flags go here.
LDFLAGS = -lpthread -lcomedi -g -lm

# list of sources
ELEVSRC = elev.c io.c main.c

# program executable file name.
TARGET = lift

# top-level rule, to compile everything.
all: $(TARGET)

# Define dependencies
DEPS = $(shell find -name "*.d")

# Define all object files.
ELEVOBJ = $(ELEVSRC:.c=.o)

# rule to link the program
$(TARGET): $(ELEVOBJ)
	gcc $^ -o $@ $(LDFLAGS)

# Compile: create object files from C source files.
%.o : %.c
	gcc $(CFLAGS) -c  $< -o $@ 

# Include dependencies, if any.
-include $(DEPS) foo

# rule for cleaning re-compilable files.
clean:
	rm -f $(TARGET) $(ELEVOBJ) $(DEPS)

rebuild:	clean all

# 
run: rebuild
	./$(TARGET)
	make clean
	

.PHONY: all rebuild clean run


#Martin Korsgaard, 2006
#Edited by Anders Petersen, 2014
