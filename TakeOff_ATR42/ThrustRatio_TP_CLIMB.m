function [Thrust] = ThrustRatio_TP_CLIMB(Mach, Altitude_ft)

global v_Mach_Thrust_CLIMB_bp v_h_ft_Thrust_CLIMB_bp Thrust_Ratio_Interp_CLIMB

%load 'Data_TP_CL'
%Mach_Vector = linspace(0,0.6,52);
%Altitude_Vector = [0 5000 10000 15000 20000 25000 30000];

[m_Mach, m_Altitude_ft] = meshgrid(v_Mach_Thrust_CLIMB_bp, v_h_ft_Thrust_CLIMB_bp);

Thrust = interp2(m_Mach, m_Altitude_ft, Thrust_Ratio_Interp_CLIMB, Mach, Altitude_ft);

end