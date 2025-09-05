function [v_Time, v_Airspeed, v_AoA, v_Sideslip, v_p, v_q, v_r, v_x_EG, v_y_EG, v_z_EG, v_quat_0, v_quat_x, v_quat_y, v_quat_z] = ...
                            Sim6DOF(s_AircraftData, v_state_0, t_end, f_delta_T, f_delta_e_deg, f_delta_a_deg, f_delta_r_deg)
    m = s_AircraftData.Mass; % A/C mass (kg)
    W = s_AircraftData.Weight; % A/C weight (N)
    T_max = s_AircraftData.Thrust_MAX; % available max thrust (N)
    S = s_AircraftData.RefSurface; % reference surface area (m^2)
    b = s_AircraftData.Wingspan; % wingspan (m)
    c = s_AircraftData.RefChord; % reference chord length (m)
    I_B = s_AircraftData.InertiaTensor; % tensor of inertia written wrt Body FoR
    CL = @(alpha_deg_, delta_e_deg_) s_AircraftData.LiftCoeff(alpha_deg_, 0, 0, 0, 0, delta_e_deg_, 0, 0);
    CD = @(alpha_deg_) s_AircraftData.DragCoeff(alpha_deg_, 0, 0, 0, 0, 0, 0, 0);
    CC = @(alpha_deg_, beta_deg_, delta_a_deg_, delta_r_deg_) s_AircraftData.CrossforceCoeff(alpha_deg_, beta_deg_, 0, 0, 0, 0, delta_a_deg_, delta_r_deg_);
    CRoll = @(alpha_deg_, beta_deg_, delta_a_deg_, delta_r_deg_, p_, r_) s_AircraftData.RollCoeff(alpha_deg_, beta_deg_, p_, 0, r_, 0, delta_a_deg_, delta_r_deg_);
    CPitch = @(alpha_deg_, delta_e_deg_, q_) s_AircraftData.PitchCoeff(alpha_deg_, 0, 0, q_, 0, delta_e_deg_, 0, 0);
    CYaw = @(alpha_deg_, beta_deg_, delta_a_deg_, delta_r_deg_, r_) s_AircraftData.YawCoeff(alpha_deg_, beta_deg_, 0, 0, r_, 0, delta_a_deg_, delta_r_deg_);

    omega_B_tilde = @(state) ...
        [  0,        -state(6),   state(5); ... % operator matrix for the left vector product by omega_B
         state(6),      0,       -state(4); ...
        -state(5),    state(4),     0     ];
    
    T_BE = @(state) quat2dcm(state(10:13).'); % change of basis matrix from Body FoR to Earth FoR
    T_EB = @(state) T_BE(state).'; % change of basis matrix from Earth FoR to Body FoR
    
    Quat_evol = @(state) 0.5 * [-state(11), -state(12), -state(13); ...
                                 state(10), -state(13),  state(12); ...
                                 state(13),  state(10), -state(11); ...
                                -state(12),  state(11),  state(10)];

    u = @(state) state(1) * cos(state(3)) * cos(state(2));
    v = @(state) state(1) * sin(state(3));
    w = @(state) state(1) * cos(state(3)) * sin(state(2));

    alpha_deg = @(state) convang(state(2), 'rad', 'deg');
    beta_deg = @(state) convang(state(3), 'rad', 'deg');

    function rho = density(h)
        [~, ~, ~, rho] = atmosisa(h);
    end
    rho = @(state) density(-state(9)); % air density (kg/m^3)
    
    function a = sound(h)
        [~, a, ~, ~] = atmosisa(h);
    end
    a = @(state) sound(-state(9)); % speed of sound (m/s)

    T = @(t) f_delta_T(t) * T_max; % thrust (N)
    
    L = @(t, state) ...
        CL(alpha_deg(state), f_delta_e_deg(t)) * 0.5 * rho(state) * state(1)^2 * S; % lift (N)
    
    D = @(t, state) ...
        CD(alpha_deg(state)) * 0.5 * rho(state) * state(1)^2 * S; % drag (N)
    
    C = @(t, state) ...
        CC(alpha_deg(state), beta_deg(state), f_delta_a_deg(t), f_delta_r_deg(t)) * 0.5 * rho(state) * state(1)^2 * S; % crossforce (N)

    function psi = quat2psi(quat)
        [psi, ~, ~] = quat2angle(quat);
    end
    
    function theta = quat2theta(quat)
        [~, theta, ~] = quat2angle(quat);
    end
    
    function phi = quat2phi(quat)
        [~, ~, phi] = quat2angle(quat);
    end

    X = @(t, state) ...
        T(t) - D(t, state) * cosd(alpha_deg(state)) + L(t, state) * sind(alpha_deg(state)) - W * sin(quat2theta(state(10:13).'));
    
    Y = @(t, state) ...
        C(t, state) + W * sin(quat2phi(state(10:13).')) * cos(quat2theta(state(10:13).'));
    
    Z = @(t, state) ...
        -D(t, state) * sind(alpha_deg(state)) - L(t, state) * cosd(alpha_deg(state)) + W * cos(quat2phi(state(10:13).')) * cos(quat2theta(state(10:13).'));

    Roll = @(t, state) ...
        CRoll(alpha_deg(state), beta_deg(state), f_delta_a_deg(t), f_delta_r_deg(t), state(4), state(6)) * 0.5 * rho(state) * state(1)^2 * S * b;
    
    Pitch = @(t, state) ...
        CPitch(alpha_deg(state), f_delta_e_deg(t), state(5)) * 0.5 * rho(state) * state(1)^2 * S * c;
    
    Yaw = @(t, state) ...
        CYaw(alpha_deg(state), beta_deg(state), f_delta_a_deg(t), f_delta_r_deg(t), state(6)) * 0.5 * rho(state) * state(1)^2 * S * b;

    V_dot = @(t, state) 1/m * (-D(t, state)*cos(state(3)) + C(t, state)*sin(state(3)) + T(t)*cos(state(2))*cos(state(3)) - W * ...
        (cos(state(2))*cos(state(3))*sin(quat2theta(state(10:13).')) - ...
        sin(state(3))*sin(quat2phi(state(10:13).'))*cos(quat2theta(state(10:13).')) - ...
        sin(state(2))*cos(state(3))*cos(quat2phi(state(10:13).'))*cos(quat2theta(state(10:13).'))));
    alpha_dot = @(t,state) 1/(m*state(1)*cos(state(3))) * (-L(t, state) - T(t)*sin(state(2)) + W * ...
        (cos(state(2))*cos(quat2phi(state(10:13).'))*cos(quat2theta(state(10:13).')) + ...
        sin(state(2))*sin(quat2theta(state(10:13).')))) + ...
        state(5) - tan(state(3)) * (state(4)*cos(state(2)) + state(6)*sin(state(2)));
    beta_dot = @(t, state) 1/(m*state(1)) * (D(t, state)*sin(state(3)) + C(t, state)*cos(state(3)) - T(t)*cos(state(2))*sin(state(3)) + W * ...
        (cos(state(2))*sin(state(3))*sin(quat2theta(state(10:13).')) + ...
        cos(state(3))*sin(quat2phi(state(10:13).'))*cos(quat2theta(state(10:13).')) - ...
        sin(state(2))*sin(state(3))*cos(quat2phi(state(10:13).'))*cos(quat2theta(state(10:13).')))) + ...
        state(4)*sin(state(2)) - state(6)*cos(state(2));

    O_3x3 = zeros(3);
    O_4x4 = zeros(4);
    O_4x3 = zeros(4, 3);
    O_3x4 = zeros(3, 4);
    
    dstate_dt = @(t, state) ...
        [V_dot(t, state); ...
         alpha_dot(t, state); ...
         beta_dot(t, state); ...
         I_B \ ([Roll(t, state); ...
                 Pitch(t, state); ...
                 Yaw(t, state)] - ...
                 omega_B_tilde(state) * I_B * state(4:6)); ...
         T_EB(state) * [u(state); ...
                        v(state); ...
                        w(state)]; ...
         Quat_evol(state) * state(4:6)];
    
    ODEoptions = odeset('AbsTol', 1e-9, 'RelTol', 1e-9);
    
    [v_Time, m_state] = ode45(dstate_dt, [0, t_end], v_state_0, ODEoptions);

    v_Airspeed = m_state(:, 1);
    v_AoA = m_state(:, 2);
    v_Sideslip = m_state(:, 3);
    
    v_p = m_state(:, 4);
    v_q = m_state(:, 5);
    v_r = m_state(:, 6);
    
    v_x_EG = m_state(:, 7);
    v_y_EG = m_state(:, 8);
    v_z_EG = m_state(:, 9);
    
    v_quat_0 = m_state(:, 10);
    v_quat_x = m_state(:, 11);
    v_quat_y = m_state(:, 12);
    v_quat_z = m_state(:, 13);
end