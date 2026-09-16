#include <stdio.h>
#include "scheduler_sim.h"

void sjf(process_t p[], int n)
{
    int time = 0;
    int completed = 0;

    printf("\n===== SJF =====\n");

    while (completed < n) {

        int selected = -1;

        for (int i = 0; i < n; i++) {

            if (p[i].remaining_time > 0 &&
                p[i].arrival_time <= time) {

                if (selected == -1 ||
                    p[i].burst_time < p[selected].burst_time) {

                    selected = i;
                }
            }
        }

        if (selected == -1) {
            time++;
            continue;
        }

        if (p[selected].first_run_time == -1)
            p[selected].first_run_time = time;

        printf("[P%d: %d-%d] ",
               p[selected].pid,
               time,
               time + p[selected].burst_time);

        time += p[selected].burst_time;

        p[selected].remaining_time = 0;
        p[selected].completion_time = time;

        completed++;
    }

    printf("\n");

    calculate_metrics(p, n);
}