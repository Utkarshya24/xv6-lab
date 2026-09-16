CC = gcc
CFLAGS = -Wall -Wextra -O2

SCHEDULER = scheduler_sim

SOURCES = main.c scheduler_sim.c fcfs.c sjf.c srtf.c priority.c rr.c

all:
	$(CC) $(CFLAGS) $(SOURCES) -o $(SCHEDULER)

bench:
	$(CC) $(CFLAGS) bench.c -o bench

clean:
	rm -f $(SCHEDULER) bench