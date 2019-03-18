#!/bin/bash




### --- Notes
#
# Do these steps for each run




### Step 1 - compute mean of each voxel time series

3dTstat -prefix tmp_tstat_<run> <run>_volreg_clean+tlrc




### Step 2 - scale data by the mean signal
#
# also constrain to extension mask

3dcalc \
-a <run>_volreg_clean+tlrc \
-b tmp_tstat_<run>+tlrc \
-c <run>_epiExt_mask+tlrc \
-expr 'c * min(200, a/b*100)*step(a)*step(b)' \
-prefix <run>_scale
