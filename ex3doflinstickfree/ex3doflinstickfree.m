close all; clear; clc

aircraftDataFileName = 'DSV_Aircraft_data.txt';
myAircraft = DSVAircraft(aircraftDataFileName);

V0 = 240;
h0 = 9000;
gamma0_deg = 0;

delta_s_deg = -1;

design0 = [0; 0.5; 0; 0];
lowerBounds = [convang(-15, 'deg', 'rad'); ...
               0.0; ...
               convang(-24, 'deg', 'rad'); ...
               convang(-3, 'deg', 'rad')];
upperBounds = [convang(18, 'deg', 'rad'); ...
               1.0; ...
               convang(16, 'deg', 'rad'); ...
               convang(3, 'deg', 'rad')];

[design, cost] = ThreeDoFTrim(myAircraft, ...
                              V0, h0, ...
                              delta_s_deg, gamma0_deg, ...
                              design0, lowerBounds, upperBounds);

alpha0 = design(1);
alpha0_deg = convang(alpha0, 'rad', 'deg');

delta_T0 = design(2);

delta_e0 = design(3);
delta_e0_deg = convang(delta_e0, 'rad', 'deg');

delta_s0 = design(4);
delta_s0_deg = convang(delta_s0, 'rad', 'deg');

state0 = [V0; alpha0; 0; 0; -h0; alpha0];

half_duration = 1.5;
delta_e_deg_impulse = 15;
t_end = 1 + 2 * half_duration + 0.01;
delta_e_deg_law = @(t) interp1(...
    [0, 1, 1+half_duration, 1 + 2 * half_duration, t_end], ...
    [delta_e0_deg, delta_e0_deg, delta_e0_deg-delta_e_deg_impulse ...
     delta_e0_deg, delta_e0_deg], ...
    t, 'pchip');

delta_T_law = @(t) interp1([0, 1] * t_end, ...
                           [1, 1] * delta_T0, ...
                           t, 'linear');

delta_s_deg_law = @(t) interp1([0, 1] * t_end, ...
                               [1, 1] * delta_s0_deg, ...
                               t, 'linear');

[time1, ...
 delta_T1, delta_e_deg1, delta_s_deg1, ...
 V1, alpha1, q1, x_EG1, z_EG1, elevation1] = ...
             ThreeDoFVabLin(t_end, state0, myAircraft, ...
                            delta_T_law, delta_e_deg_law, delta_s_deg_law);

delta_e1 = convang(delta_e_deg1, 'deg', 'rad');
state0 = [V1(end); ...
          alpha1(end); ...
          q1(end); ...
          x_EG1(end); ...
          z_EG1(end); ...
          elevation1(end); ...
          0; ...
          delta_e1(end)];

t_end = 10;

delta_T_law = @(t) interp1([0, 1] * t_end, ...
                           [1, 1] * delta_T0, ...
                           t, 'linear');

delta_s_deg_law = @(t) interp1([0, 1] * t_end, ...
                               [1, 1] * delta_s0_deg, ...
                               t, 'linear');

delta_tab_deg_law = @(t) interp1([0, 1] * t_end, ...
                                 [1, 1] * 0, ...
                                 t, 'linear');

[time2, delta_T2, delta_s_deg2, delta_tab_deg2, ...
 V2, alpha2, q2, x_EG2, z_EG2, elevation2, delta_e_dot2, delta_e2, ...
 CH_e2, HingeMom2] = ...
    ThreeDoFVabLinStickfree(t_end, state0, myAircraft, delta_T_law, ...
                            delta_s_deg_law, delta_tab_deg_law);

delta_e_dot1 = timeDerivative(time1, delta_e1);
delta_tab_deg1 = zeros(length(time1), 1);
nan1 = NaN(length(time1), 1);
nan2 = NaN(length(time2), 1);

mu_x = myAircraft.mu_x;
S_e = myAircraft.S_e;
Lambda_e = myAircraft.Lambda_e;
e_e = myAircraft.ec_adim;
x_C_e = myAircraft.x_C_e;
mac_e = myAircraft.mac_e;
mass_e = myAircraft.mass_e;
k_e = myAircraft.k_e;
CH_e_0 = myAircraft.Ch_e_0;
CH_e_alpha = myAircraft.Ch_e_alpha;
CH_e_delta_e = myAircraft.Ch_e_delta_e;
CH_e_delta_s = myAircraft.Ch_e_delta_s;
CH_e_delta_tab = myAircraft.Ch_e_delta_tab;
CH_e_delta_e_dot = myAircraft.Ch_e_delta_e_dot;
CH_e_alpha_dot = myAircraft.Ch_e_alpha_dot;
CH_e_q = myAircraft.Ch_e_q;
eps0 = myAircraft.eps_0;
Deps_Dalpha = myAircraft.DepsDalpha;

delta_s1 = convang(delta_s_deg1, 'deg', 'rad');
delta_tab1 = convang(delta_tab_deg1, 'deg', 'rad');
alpha_H1 = (1 - Deps_Dalpha) * (alpha1 - mu_x) - eps0 + delta_s1 + mu_x;
[~, ~, ~, dens1] = atmosisa(-z_EG1);

CH_e1 = CH_e_0 + CH_e_alpha * alpha_H1 + CH_e_delta_e * delta_e1 + ...
    CH_e_delta_s * delta_s1 + CH_e_delta_tab * delta_tab1 + ...
    mac_e./(2*V1) .* ( ...
    CH_e_alpha_dot * (1 - Deps_Dalpha) * timeDerivative(time1, alpha1) + ...
    CH_e_q * q1 + CH_e_delta_e_dot * delta_e_dot1);

HingeMom1 = CH_e1 .* 0.5 .* dens1 .* V1.^2 .* S_e .* mac_e;

x_EG_traj = [x_EG1; x_EG2];
z_EG_traj = [z_EG1; z_EG2];
elevation_traj = [elevation1; elevation2];

delta_T1 = [delta_T1; nan2];
delta_s_deg1 = [delta_s_deg1; nan2];
delta_tab_deg1 = [delta_tab_deg1; nan2];
V1 = [V1; nan2];
alpha1 = [alpha1; nan2];
x_EG1 = [x_EG1; nan2];
z_EG1 = [z_EG1; nan2];
elevation1 = [elevation1; nan2];
q1 = [q1; nan2];
delta_e1 = [delta_e1; nan2];
delta_e_dot1 = [delta_e_dot1; nan2];
CH_e1 = [CH_e1; nan2];
HingeMom1 = [HingeMom1; nan2];

delta_T2 = [nan1; delta_T2];
delta_s_deg2 = [nan1; delta_s_deg2];
delta_tab_deg2 = [nan1; delta_tab_deg2];
V2 = [nan1; V2];
alpha2 = [nan1; alpha2];
x_EG2 = [nan1; x_EG2];
z_EG2 = [nan1; z_EG2];
elevation2 = [nan1; elevation2];
q2 = [nan1; q2];
delta_e2 = [nan1; delta_e2];
delta_e_dot2 = [nan1; delta_e_dot2];
CH_e2 = [nan1; CH_e2];
HingeMom2 = [nan1; HingeMom2];

time = [time1; time2+time1(end)];
delta_T = [delta_T1, delta_T2];
delta_s_deg = [delta_s_deg1, delta_s_deg2];
delta_tab_deg = [delta_tab_deg1, delta_tab_deg2];
V = [V1, V2];
alpha = [alpha1, alpha2];
x_EG = [x_EG1, x_EG2];
z_EG = [z_EG1, z_EG2];
elevation = [elevation1, elevation2];
q = [q1, q2];
delta_e = [delta_e1, delta_e2];
delta_e_dot = [delta_e_dot1, delta_e_dot2];
CH_e = [CH_e1, CH_e2];
HingeMom = [HingeMom1, HingeMom2];

lgnd = {"Stick fixed", "Stick free"};

stackedPlot3(time, delta_T, delta_s_deg, delta_tab_deg, ...
    {"Simualtion time (s)", "$\delta_\mathrm{T}$", ...
     "$\delta_\mathrm{s}$ (deg)", "$\delta_\mathrm{t}$ (deg)"}, ...
    {}, lgnd, 'ex3doflinstickfreeinputcommands.pdf')

alpha_deg = convang(alpha, 'rad', 'deg');
stackedPlot2(time, V, alpha_deg, ...
    {"Simulation time (s)", "Airspeed (m/s)", "$\alpha$ (deg)"}, ...
    {}, lgnd, 'ex3doflinstickfreeVa.pdf')

stackedPlot2(time, x_EG, -z_EG, ...
    {"Simulation time (s)", "$x_{\mathrm{E},G}$ (m)", "Altitude (m)"}, ...
    {}, lgnd, 'ex3doflinstickfreecogxh.pdf')

elevation_deg = convang(elevation, 'rad', 'deg');
q_degps = convangvel(q, 'rad/s', 'deg/s');
stackedPlot2(time, elevation_deg, q_degps, ...
    {"Simulation time (s)", "$\theta$ (deg)", "$q$ (deg/s)"}, ...
    {}, lgnd, 'ex3doflinstickfreethetaq.pdf')

delta_e_deg = convang(delta_e, 'rad', 'deg');
delta_e_dot_degps = convangvel(delta_e_dot, 'rad/s', 'deg/s');
stackedPlot2(time, delta_e_deg, delta_e_dot_degps, ...
    {"Simulation time (s)", "$\delta_\mathrm{e}$ (deg)", ...
     "$\dot\delta_\mathrm{e}$ (deg/s)"}, ...
     {}, lgnd, 'ex3doflinstickfreedeltae.pdf')

stackedPlot2(time, CH_e, HingeMom, ...
    {"Simulation time (s)", "$C_{\mathcal{H}_\mathrm{e}}$", ...
     "$\mathcal{H}_\mathrm{e,A}$ (N m)"}, ...
     {}, lgnd, 'ex3doflinstickfreeCH.pdf')

Nt = length(time);
y_EG = zeros(Nt, 1);
phi = y_EG;
psi = y_EG;
trajectoryView(time, x_EG_traj, y_EG, z_EG_traj, ...
               phi, elevation_traj, psi, ...
               120, 4, ...
               'ex3doflinstickfreetrajectory.pdf')