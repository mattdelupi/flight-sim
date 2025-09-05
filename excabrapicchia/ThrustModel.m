function T = ThrustModel(inputs, myAircraft)

    alpha_deg = inputs(1);
    beta_deg = inputs(2);
    delta_T = inputs(3);
    delta_e_deg = inputs(4);
    delta_s_deg = inputs(5);
    delta_a_deg = inputs(6);
    delta_r_deg = inputs(7);
    p_degps = inputs(8);
    q_degps = inputs(9);
    r_degps = inputs(10);
    altitude = inputs(11);
    airspeed = inputs(12);

    [~, ~, sound, ~] = atmosisa(altitude);
    mach = airspeed / sound;

    mach_data = importdata('T_vs_Mach_h1.txt', ',', 3).data(:, 1);
    altitude_data = [0; 3000; 6000; 9000; 12000];
    [ALTITUDE, MACH] = meshgrid(altitude_data, mach_data);

    T_data_h0 = importdata('T_vs_Mach_h1.txt', ',', 3).data(:, 2);
    T_data_h3000 = importdata('T_vs_Mach_h2.txt', ',', 3).data(:, 2);
    T_data_h6000 = importdata('T_vs_Mach_h3.txt', ',', 3).data(:, 2);
    T_data_h9000 = importdata('T_vs_Mach_h4.txt', ',', 3).data(:, 2);
    T_data_h12000 = importdata('T_vs_Mach_h5.txt', ',', 3).data(:, 2);
    T_data = [T_data_h0, T_data_h3000, T_data_h6000, ...
                                            T_data_h9000, T_data_h12000];
    T_data = T_data ./ max(max(T_data)) .* myAircraft.T;

    T_max = interp2(ALTITUDE, MACH, T_data, altitude, mach, 'spline');

    T = delta_T * T_max;

end