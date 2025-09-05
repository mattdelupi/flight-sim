This project runs take-off + climb simulations of an ATR-42-600 aircraft model.

INSTRUCTIONS

STEP 1
Run the MATLAB live scripts in sequence:

    a) "setup_Step_0_Build_AircraftData.mlx"
        - Creates the file "AircraftData.mat"

    b) "setup_Step_1_Display_AircraftData.mlx"
        - Loads the file "AircraftData.mat"

    c) "setup_Step_2_Prepare_TakeOff_Sim.mlx"
        - Loads the file "AircraftData.mat"
        - Prepares the simulation in Simulink.

STEP 2
Open the Simulink project takeoff_12.slx (or *_13.slx) 
and play around with simulations.
Note: the projects relies on several variable that must be 
defined into the MATLAB workspace (which are calculated 
by "setup_Step_2_Prepare_TakeOff_Sim.mlx").

STEP 3
The MATLAB live script "TP_TO.mlx" (Turbo-Prop Take-Off) is a side-project
that implements simplified methods to calculate the total take-off runs,
as discussed in basic courses on aircraft performance.
