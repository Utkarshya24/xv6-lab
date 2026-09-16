#include <stdio.h>
#include "scheduler_sim.h"

#define QUANTUM 2

void rr(process_t p[], int n)
{
    int queue[100];
    int front = 0;
    int rear = 0;

    int added[100] = {0};

    int time = 0;
    int completed = 0;

    printf("\n===== ROUND ROBIN (Q=%d) =====\n",
           QUANTUM);

    while (completed < n) {

        /* Add newly arrived processes */
        for (int i = 0; i < n; i++) {

            if (!added[i] &&
                p[i].arrival_time <= time) {

                queue[rear++] = i;
                added[i] = 1;
            }
        }

        /* CPU idle */
        if (front == rear) {
            time++;
            continue;
        }

        int idx = queue[front++];

        if (p[idx].first_run_time == -1)
            p[idx].first_run_time = time;

        int slice = QUANTUM;

        if (p[idx].remaining_time < slice)
            slice = p[idx].remaining_time;

        printf("[P%d:%d-%d] ",
               p[idx].pid,
               time,
               time + slice);

        for (int t = 0; t < slice; t++) {

            p[idx].remaining_time--;
            time++;

            for (int i = 0; i < n; i++) {

                if (!added[i] &&
                    p[i].arrival_time <= time) {

                    queue[rear++] = i;
                    added[i] = 1;
                }
            }

            if (p[idx].remaining_time == 0)
                break;
        }

        if (p[idx].remaining_time == 0) {

            p[idx].completion_time = time;
            completed++;

        } else {

            queue[rear++] = idx;
        }
    }

    printf("\n");

    calculate_metrics(p, n);
}