function [design, Jval] = ThreeDoFTrim(myAircraft, ...
                                       airspeed, altitude0, ...
                                       delta_s_deg, gamma0_deg, ...
                                       design0, lowerBounds, upperBounds)

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

alpha = @(xi) xi(1);
delta_T = @(xi) xi(2);
delta_e = @(xi) xi(3);
delta_s = @(xi) xi(4);

gamma0 = convang(gamma0_deg, 'deg', 'rad');

q = 0;

[~, ~, ~, rho] = atmosisa(altitude0);
mu = W / S / (rho * b * g);

[~, sound, ~, ~] = atmosisa(altitude0);
mach = airspeed / sound;
Thrust = @(xi) delta_T(xi) * ThrustModel(altitude0, mach);
Cm_T = @(xi) delta_T(xi) * (Cm_T_0 + Cm_T_alpha * alpha(xi));

M32 = -c/b / (4 * mu) * airspeed*c/k_y^2 * Cm_alpha_dot;
massmatrix = [1,  0,  0, 0, 0, 0; ...
              0,  1,  0, 0, 0, 0; ...
              0, M32, 1, 0, 0, 0; ...
              0,  0,  0, 1, 0, 0; ...
              0,  0,  0, 0, 1, 0; ...
              0,  0,  0, 0, 0, 1];

Vdot = @(xi) ...
    -0.5 * S/W * rho * airspeed^2 * g * ( ...
        CD0 + k * (CL_alpha*alpha(xi) + CL_delta_e*delta_e(xi) + ...
                                       CL_delta_s*delta_s(xi))^m) ...
    +Thrust(xi)/W * g * cos(alpha(xi) - mu_x - mu_T) ...
    -g * sin(gamma0);

alphadot = @(xi) 1 / (1 + c/b / (4 * mu) * CL_alpha_dot) * ( ...
    -0.5 * S/W * rho * airspeed * g * ( ...
        CL_alpha*alpha(xi) + CL_delta_e*delta_e(xi) + ...
                                                CL_delta_s*delta_s(xi)) ...
       +q * (1 - c/b / (4 * mu) * CL_q) ...
       -Thrust(xi)/W * g/airspeed * sin(alpha(xi) - mu_x - mu_T) ...
       +g/airspeed* cos(gamma0));

qdot = @(xi) airspeed^2/k_y^2 * c/b / (2 * mu) * ( ...
    Cm0 + Cm_alpha*alpha(xi) + Cm_q*q*c/(2*airspeed) ...
   +Cm_delta_e*delta_e(xi) + Cm_delta_s*delta_s(xi) + Cm_T(xi));

xEGdot = @(xi) airspeed * cos(gamma0);

zEGdot = @(xi) -airspeed * sin(gamma0);

thetadot = @(xi) q;

dstate_dt = @(xi) massmatrix \ [Vdot(xi); ...
                                alphadot(xi); ...
                                qdot(xi); ...
                                xEGdot(xi); ...
                                zEGdot(xi); ...
                                thetadot(xi)];

function J = cost(dstate_dt)
    J = dstate_dt(1)^2 + dstate_dt(2)^2 + dstate_dt(3)^2 + dstate_dt(6)^2;
end

function [c, ceq] = nonLinCon(~)
    c = [];
    ceq = [];
end

Aeq = zeros(4); Aeq(4, 4) = 1;
beq = zeros(4, 1); beq(4) = convang(delta_s_deg, 'deg', 'rad');

trimOptions = optimset('tolfun', 1e-9, 'Algorithm', 'interior-point');
[design, Jval] = fmincon(@(xi) cost(dstate_dt(xi)), ...
                         design0, ...
                         [], [], ...
                         Aeq, beq, ...
                         lowerBounds, upperBounds, ...
                         nonLinCon, ...
                         trimOptions);

end