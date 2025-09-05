function pitchCharacteristicsPlot(myAircraft, ModelsInputs, alpha_deg_limits, ...
                                  delta_e_deg_cases, q_degps_cases, filename)

    Ndelta = length(delta_e_deg_cases);

    alpha_deg = linspace(alpha_deg_limits(1), alpha_deg_limits(2), 255);

    y1 = zeros(255, Ndelta);
    y2 = y1;
    y3 = y1;
    y4 = y1;
    y5 = y1;
    y6 = y1;
    for idelta = 1 : Ndelta
        delta_e_labels{idelta} = ...
            strcat("$\delta_\mathrm{e}$ = ", num2str(delta_e_deg_cases(idelta)), " deg");
        ModelsInputs([3, 8]) = [delta_e_deg_cases(idelta), q_degps_cases(1)];
        for i = 1 : 255
            y1(i, idelta) = myAircraft.PitchCoeffModel([alpha_deg(i), ModelsInputs]);
        end
        ModelsInputs([3, 8]) = [delta_e_deg_cases(idelta), q_degps_cases(2)];
        for i = 1 : 255
            y2(i, idelta) = myAircraft.PitchCoeffModel([alpha_deg(i), ModelsInputs]);
        end
        ModelsInputs([3, 8]) = [delta_e_deg_cases(idelta), q_degps_cases(3)];
        for i = 1 : 255
            y3(i, idelta) = myAircraft.PitchCoeffModel([alpha_deg(i), ModelsInputs]);
        end
        ModelsInputs([3, 8]) = [delta_e_deg_cases(idelta), q_degps_cases(4)];
        for i = 1 : 255
            y4(i, idelta) = myAircraft.PitchCoeffModel([alpha_deg(i), ModelsInputs]);
        end
        ModelsInputs([3, 8]) = [delta_e_deg_cases(idelta), q_degps_cases(5)];
        for i = 1 : 255
            y5(i, idelta) = myAircraft.PitchCoeffModel([alpha_deg(i), ModelsInputs]);
        end
        ModelsInputs([3, 8]) = [delta_e_deg_cases(idelta), q_degps_cases(6)];
        for i = 1 : 255
            y6(i, idelta) = myAircraft.PitchCoeffModel([alpha_deg(i), ModelsInputs]);
        end
    end

    for iplot = 1 : 6
        q_labels{iplot} = strcat("$q =", num2str(q_degps_cases(iplot)), "$ (deg/s)");
    end

    stackedPlot3x2(alpha_deg, ...
                   y1, y2, y3, y4, y5, y6, ...
                   {"$\alpha_\mathrm{B}$ (deg)", "$C_\mathcal{M}$", "", ...
                    "$C_\mathcal{M}$", "", "$C_\mathcal{M}$", ""}, ...
                   q_labels, delta_e_labels, filename)

end