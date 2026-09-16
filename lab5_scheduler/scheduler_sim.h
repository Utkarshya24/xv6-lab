#ifndef SCHEDULER_SIM_H
#define SCHEDULER_SIM_H

typedef struct process {
    int pid;
    int arrival_time;
    int burst_time;
    int remaining_time;
    int priority;

    int completion_time;
    int first_run_time;
} process_t;

void reset_processes(process_t processes[], int n);

void calculate_metrics(process_t processes[], int n);

void print_processes(process_t processes[], int n);

void print_average_metrics(process_t processes[], int n);

#endif