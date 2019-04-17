# motionAmp
This project processes video to amplify and segment motion. 



#### analysis pipeline:

1. amplify motion using a phase-based eularian approach using complex steerable pyramids
2. create a velocity vector field from the amplified motion
3. use the velocity vector field, along with other feature of the video to segment the video into meaningful parts. 



### project organizational directories:

**data** - where the original video, and all intermediate data is stored.

**experiments** - contains scripts performing step by step analysis

analysis pipeline : **motionAmp** -  > **mVectorField** -> **segment**

**tests** - contains functions for generating synthetic test input for validation

**utils** - functions that are used in multiple places or are helper functions











​	





