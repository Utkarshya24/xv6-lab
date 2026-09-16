#include <stdio.h>
#include "scheduler_sim.h"

void priority_scheduling(process_t p[], int n)
{
    int time = 0;
    int completed = 0;

    printf("\n===== PRIORITY =====\n");

    while (completed < n) {

        int selected = -1;

        for (int i = 0; i < n; i++) {

            if (p[i].remaining_time > 0 &&
                p[i].arrival_time <= time) {

                if (selected == -1 ||
                    p[i].priority < p[selected].priority ||
                    (p[i].priority == p[selected].priority &&
                     p[i].arrival_time < p[selected].arrival_time)) {

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

        printf("[P%d:%d-%d] ",
               p[selected].pid,
               time,
               time + 1);

        p[selected].remaining_time--;
        time++;

        if (p[selected].remaining_time == 0) {
            p[selected].completion_time = time;
            completed++;
        }
    }

    printf("\n");

    calculate_metrics(p, n);
}