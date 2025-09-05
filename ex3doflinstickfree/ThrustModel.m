function T = ThrustModel(altitude, mach)

T_max = convforce(11200, 'lbf', 'N');

function sound = Sound(altitude)
    [~, ~, sound, ~] = atmosisa(altitude);
end
a = @(altitude) Sound(altitude);
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
T_data = T_data ./ 3081.6 .* T_max;

T = interp2(ALTITUDE, MACH, T_data, altitude, mach, 'spline');

end