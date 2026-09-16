#include <stdio.h>
#include "scheduler_sim.h"

void reset_processes(process_t processes[], int n)
{
    for (int i = 0; i < n; i++) {
        processes[i].remaining_time = processes[i].burst_time;
        processes[i].completion_time = -1;
        processes[i].first_run_time = -1;
    }
}

void calculate_metrics(process_t processes[], int n)
{
    double total_waiting = 0;
    double total_turnaround = 0;
    double total_response = 0;

    printf("\nPID\tWaiting\tTurnaround\tResponse\n");

    for (int i = 0; i < n; i++) {

        int turnaround =
            processes[i].completion_time -
            processes[i].arrival_time;

        int waiting =
            turnaround -
            processes[i].burst_time;

        int response =
            processes[i].first_run_time -
            processes[i].arrival_time;

        printf("P%d\t%d\t%d\t\t%d\n",
               processes[i].pid,
               waiting,
               turnaround,
               response);

        total_waiting += waiting;
        total_turnaround += turnaround;
        total_response += response;
    }

    printf("\nAverage Waiting Time    : %.2f\n",
           total_waiting / n);

    printf("Average Turnaround Time : %.2f\n",
           total_turnaround / n);

    printf("Average Response Time   : %.2f\n",
           total_response / n);
}

void print_processes(process_t processes[], int n)
{
    printf("\nPID\tAT\tBT\tPriority\n");

    for (int i = 0; i < n; i++) {
        printf("P%d\t%d\t%d\t%d\n",
               processes[i].pid,
               processes[i].arrival_time,
               processes[i].burst_time,
               processes[i].priority);
    }
}