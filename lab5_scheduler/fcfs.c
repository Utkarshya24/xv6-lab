#include <stdio.h>
#include "scheduler_sim.h"

void fcfs(process_t p[], int n)
{
    int time = 0;

    printf("\n===== FCFS =====\n");

    for (int i = 0; i < n; i++) {

        if (time < p[i].arrival_time)
            time = p[i].arrival_time;

        if (p[i].first_run_time == -1)
            p[i].first_run_time = time;

        printf("[P%d: %d-%d] ",
               p[i].pid,
               time,
               time + p[i].burst_time);

        time += p[i].burst_time;

        p[i].remaining_time = 0;
        p[i].completion_time = time;
    }

    printf("\n");

    calculate_metrics(p, n);
}