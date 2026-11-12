ALL-IN-ONE PROGRAM
3DOF SIMULATION SAGITTARIUS
Multirun with variable mass + data taken from the center-of-gravity and sustain files
(still to be implemented properly)


HOW TO USE:
- open CenterOfGravity and load data
- open Sustain and load data
- open Warhead and load data
- open aero_guid_dat.m to run a multirun


Simple variable mass: inputs
- initial and final mass
- dm/dt -> taken from the propellant consumption in the sustain.m file
- initial Iyy (full grain); final Iyy (empty grain)

TODO:
- modify the force Fz so that the mass varies with time (DONE)
- take mdot from the sustain file (DONE)
- take the initial launch position of the sustain (x_ini, z_ini)
    from the booster file (initial speed as well)
- implement PK functions from the warhead and the consequent stop
- implement aerodynamics and moment control

ISSUES:
- different masses between the center-of-gravity file and the CAD => only the
    mass variation with mdot, saved in mass_w_time.mat, is used as input
