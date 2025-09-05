function [ret] = f_CL_TO(AircraftData, alpha)

    if (alpha < AircraftData.Aerodynamics.Interp.v_AoA_TO_1(1))

        ret = AircraftData.Aerodynamics.Interp.v_CL_TO_bp_1(1);

    elseif (alpha >= AircraftData.Aerodynamics.Interp.v_AoA_TO_1(1)) ... 
        && (alpha < AircraftData.Aerodynamics.Interp.v_AoA_TO_1(end))
        
        ret = AircraftData.Aerodynamics.Interp.f_CL_TO_1(alpha);
    
    elseif (alpha >= AircraftData.Aerodynamics.Interp.v_AoA_TO_1(end)) ...
        && (alpha < AircraftData.Aerodynamics.Interp.v_AoA_TO_2(end))
    
        ret = AircraftData.Aerodynamics.Interp.f_CL_TO_2(alpha);
    
    else
    
        ret = AircraftData.Aerodynamics.Interp.v_CL_TO_bp_2(end);
        
    end
end