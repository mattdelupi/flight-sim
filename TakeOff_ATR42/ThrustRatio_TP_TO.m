function [Thrust] = ThrustRatio_TP_TO(Mach,Altitude)
%ThrustRatioTP_TO 
load 'Data_TP_TO'

Mach_Vector = linspace(0,0.6,52);
Altitude_Vector = [0 5000 10000 15000];
[MACH_Vector,ALTITUDE_Vector] = meshgrid(Mach_Vector,Altitude_Vector);

Thrust = interp2(MACH_Vector,ALTITUDE_Vector,Thrust_Ratio_Interp_TO,Mach,Altitude);

end
