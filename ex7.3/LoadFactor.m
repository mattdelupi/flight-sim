function [f_xA, f_yA, f_zA] = LoadFactor(time, u, v, w, alpha_deg, quat0, quatx, quaty, quatz)

    Nt = length(time);

    T_AB = @(alpha_deg) [cosd(-alpha_deg), 0, -sind(-alpha_deg); ...
                                0        , 1,         0        ; ...
                         sind(-alpha_deg), 0,  cosd(-alpha_deg)];

    V_E = zeros(Nt, 3);
    g_A = V_E;
    for it = 1 : Nt
        T_BE = quat2dcm([quat0(it), quatx(it), quaty(it), quatz(it)]);
        T_EB = T_BE.';
        V_E(it, :) = (T_EB * [u(it); v(it); w(it)]).';
        g_A(it, :) = (T_AB(alpha_deg(it)) * T_BE * [0; 0; 9.81]).';
    end
    
    a_E = timeDerivative(time, V_E);
    a_A = zeros(Nt, 3);
    for it = 1 : Nt
        T_BE = quat2dcm([quat0(it), quatx(it), quaty(it), quatz(it)]);
        a_A(it, :) = (T_AB(alpha_deg(it)) * T_BE * a_E(it, :).').';
    end

    f_A = (g_A - a_A) ./ 9.81;

    f_xA = f_A(:, 1);
    f_yA = f_A(:, 2);
    f_zA = f_A(:, 3);

end