#include <stdio.h>
#include <stdlib.h>
#include "scheduler_sim.h"

#define MAX_PROCESSES 100

void fcfs(process_t p[], int n);
void sjf(process_t p[], int n);
void srtf(process_t p[], int n);
void priority_scheduling(process_t p[], int n);
void rr(process_t p[], int n);

int load_workload(const char *filename, process_t p[])
{
    FILE *file = fopen(filename, "r");

    if (!file) {
        perror("Unable to open workload");
        exit(1);
    }

    int n = 0;

    while (n < MAX_PROCESSES &&
           fscanf(file,
                  "%d %d %d %d",
                  &p[n].pid,
                  &p[n].arrival_time,
                  &p[n].burst_time,
                  &p[n].priority) == 4) {

        p[n].remaining_time = p[n].burst_time;
        p[n].completion_time = -1;
        p[n].first_run_time = -1;

        n++;
    }

    fclose(file);

    return n;
}

int main()
{
    process_t original[MAX_PROCESSES];
    process_t processes[MAX_PROCESSES];

    int n = load_workload("workload.txt", original);

    printf("Loaded %d processes\n", n);

    print_processes(original, n);

    /* FCFS */
    for (int i = 0; i < n; i++)
        processes[i] = original[i];

    fcfs(processes, n);

    /* SJF */
    for (int i = 0; i < n; i++)
        processes[i] = original[i];

    reset_processes(processes, n);

    sjf(processes, n);

    /* SRTF */
    for (int i = 0; i < n; i++)
        processes[i] = original[i];

    reset_processes(processes, n);

    srtf(processes, n);

    /* Priority */
    for (int i = 0; i < n; i++)
        processes[i] = original[i];

    reset_processes(processes, n);

    priority_scheduling(processes, n);

    /* Round Robin */
    for (int i = 0; i < n; i++)
        processes[i] = original[i];

    reset_processes(processes, n);

    rr(processes, n);

    return 0;
}