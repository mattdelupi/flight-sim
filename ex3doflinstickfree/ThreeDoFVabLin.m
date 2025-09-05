function [time, ...
          delta_T, delta_e_deg, delta_s_deg, ...
          V, alpha, q, x_EG, z_EG, theta] = ...
                      ThreeDoFVabLin(t_end, state0, ...
                                     myAircraft, ...
                                     delta_T_law, ...
                                     delta_e_deg_law, delta_s_deg_law)

delta_e_law = @(t) convang(delta_e_deg_law(t), 'deg', 'rad');
delta_s_law = @(t) convang(delta_s_deg_law(t), 'deg', 'rad');

g = 9.81;
W = myAircraft.mass * g;
S = myAircraft.S;
c = myAircraft.mac;
b = myAircraft.b;
mu_x = myAircraft.mu_x;
mu_T = myAircraft.mu_T;
k = myAircraft.K;
m = myAircraft.m;
k_y = myAircraft.k_y;
CL_alpha = myAircraft.CL_alpha;
CL_delta_e = myAircraft.CL_delta_e;
CL_delta_s = myAircraft.CL_delta_s;
CL_alpha_dot = myAircraft.CL_alpha_dot;
CL_q = myAircraft.CL_q;
CD0 = myAircraft.CD_0;
Cm0 = myAircraft.Cm_0;
Cm_alpha = myAircraft.Cm_alpha;
Cm_delta_e = myAircraft.Cm_delta_e;
Cm_delta_s = myAircraft.Cm_delta_s;
Cm_alpha_dot = myAircraft.Cm_alpha_dot;
Cm_q = myAircraft.Cm_q;
Cm_T_0 = myAircraft.Cm_T_0;
Cm_T_alpha = myAircraft.Cm_T_alpha;

airspeed = @(state) state(1);
alpha_deg = @(state) convang(state(2), 'rad', 'deg');
elevation = @(state) state(6);
q_degps = @(state) convangvel(state(3), 'rad/s', 'deg/s');
altitude = @(state) -state(5);

function a = sound(altitude)
    [~, a, ~, ~] = atmosisa(altitude);
end
mach = @(state) airspeed(state) / sound(altitude(state));
Thrust = @(t, state) ...
    delta_T_law(t) * ThrustModel(altitude(state), mach(state));
Cm_T = @(t, state) delta_T_law(t) * (Cm_T_0 + Cm_T_alpha * state(2));

function rho = density(h)
    [~, ~, ~, rho] = atmosisa(h);
end
rho = @(state) density(altitude(state));
mu = @(state) W / S / (rho(state) * b * g);

M32 = @(state) -c/b / (4 * mu(state)) * airspeed(state)*c/k_y^2 * Cm_alpha_dot;
massmatrix = @(t, state) [1,      0,     0, 0, 0, 0; ...
                          0,      1,     0, 0, 0, 0; ...
                          0, M32(state), 1, 0, 0, 0; ...
                          0,      0,     0, 1, 0, 0; ...
                          0,      0,     0, 0, 1, 0; ...
                          0,      0,     0, 0, 0, 1];

Vdot = @(t, state) ...
    -0.5 * S/W * rho(state) * airspeed(state)^2 * g * ( ...
        CD0 + k * (CL_alpha*state(2) + CL_delta_e*delta_e_law(t) + ...
                                       CL_delta_s*delta_s_law(t))^m) ...
    +Thrust(t, state)/W * g * cos(state(2) - mu_x - mu_T) ...
    +g * sin(state(2) - mu_x - elevation(state));

alphadot = @(t, state) 1 / (1 + c/b / (4 * mu(state)) * CL_alpha_dot) * ( ...
    -0.5 * S/W * rho(state) * airspeed(state) * g * ( ...
        CL_alpha*state(2) + CL_delta_e*delta_e_law(t) + CL_delta_s*delta_s_law(t)) ...
    +state(3) * (1 - c/b / (4 * mu(state)) * CL_q) ...
    -Thrust(t, state)/W * g/airspeed(state) * sin(state(2) - mu_x - mu_T) ...
    +g/airspeed(state) * cos(state(2) - mu_x - elevation(state)));

qdot = @(t, state) airspeed(state)^2/k_y^2 * c/b / (2 * mu(state)) * ( ...
    Cm0 + Cm_alpha*state(2) + c/(2*airspeed(state))*(Cm_q*state(3) ) ...
   +Cm_delta_e*delta_e_law(t) + Cm_delta_s*delta_s_law(t) + Cm_T(t, state));

xEGdot = @(t, state) airspeed(state) * cos(state(2) - mu_x - elevation(state));

zEGdot = @(t, state) airspeed(state) * sin(state(2) - mu_x - elevation(state));

thetadot = @(t, state) state(3);

dstate_dt = @(t, state) massmatrix(t, state) \ ...
                        [ Vdot(t, state); ...
                          alphadot(t, state); ...
                          qdot(t, state); ...
                          xEGdot(t, state); ...
                          zEGdot(t, state); ...
                          thetadot(t, state) ];

ODEoptions = odeset('AbsTol', 1e-9, 'RelTol', 1e-9);

[time, state] = ode45(dstate_dt, [0, t_end], state0, ODEoptions);

delta_T = delta_T_law(time);         delta_T = delta_T(:);
delta_e_deg = delta_e_deg_law(time); delta_e_deg = delta_e_deg(:);
delta_s_deg = delta_s_deg_law(time); delta_s_deg = delta_s_deg(:);
V = state(:, 1);
alpha = state(:, 2);
q = state(:, 3);
x_EG = state(:, 4);
z_EG = state(:, 5);
theta = state(:, 6);

end