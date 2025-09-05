function SaveAircraftData(filename, m, T_max, S, b, c, Ixx, Iyy, Izz, Ixy, Ixz, Iyz, f_CL, f_CD, f_CC, f_CRoll, f_CPitch, f_CYaw)
    Mass = m;
    Weight = m * 9.81;
    Thrust_MAX = T_max;
    RefSurface = S;
    Wingspan = b;
    RefChord = c;
    InertiaTensor = [Ixx, Ixy, Ixz; ...
                                    Ixy, Iyy, Iyz; ...
                                    Ixz, Iyz, Izz];
    LiftCoeff = @(alpha_deg, beta_deg, p, q, r, delta_e_deg, delta_a_deg, delta_r_deg) f_CL(alpha_deg, beta_deg, p, q, r, delta_e_deg, delta_a_deg, delta_r_deg);
    DragCoeff = @(alpha_deg, beta_deg, p, q, r, delta_e_deg, delta_a_deg, delta_r_deg) f_CD(alpha_deg, beta_deg, p, q, r, delta_e_deg, delta_a_deg, delta_r_deg);
    CrossforceCoeff = @(alpha_deg, beta_deg, p, q, r, delta_e_deg, delta_a_deg, delta_r_deg) f_CC(alpha_deg, beta_deg, p, q, r, delta_e_deg, delta_a_deg, delta_r_deg);
    RollCoeff = @(alpha_deg, beta_deg, p, q, r, delta_e_deg, delta_a_deg, delta_r_deg) f_CRoll(alpha_deg, beta_deg, p, q, r, delta_e_deg, delta_a_deg, delta_r_deg);
    PitchCoeff = @(alpha_deg, beta_deg, p, q, r, delta_e_deg, delta_a_deg, delta_r_deg) f_CPitch(alpha_deg, beta_deg, p, q, r, delta_e_deg, delta_a_deg, delta_r_deg);
    YawCoeff = @(alpha_deg, beta_deg, p, q, r, delta_e_deg, delta_a_deg, delta_r_deg) f_CYaw(alpha_deg, beta_deg, p, q, r, delta_e_deg, delta_a_deg, delta_r_deg);
    save(filename);
end