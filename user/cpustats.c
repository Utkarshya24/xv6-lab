
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(void) {
    struct cpustats st;
    if(cpustats(&st) < 0) {
        printf("cpustats call failed\n");
        exit(1);
    }
    printf("procs=%d ticks=%d\n", st.nproc, st.ticks);
    exit(0);
}
