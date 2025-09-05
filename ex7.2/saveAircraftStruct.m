function saveAircraftStruct(aircraftName, ...
                S, b, c, m, I_B, ...
                T_max, ThrustModel, ...
                LiftCoeffModel, DragCoeffModel, CrossforceCoeffModel, ...
                RollCoeffModel, PitchCoeffModel, YawCoeffModel)

    myAircraft.S = S;
    myAircraft.b = b;
    myAircraft.c = c;
    myAircraft.m = m;
    myAircraft.W = m * 9.81;
    myAircraft.I_B = I_B;
    myAircraft.T_max = T_max;
    myAircraft.ThrustModel = @(inputs) ThrustModel(inputs, myAircraft);
    myAircraft.DragCoeffModel = @(inputs) DragCoeffModel(inputs);
    myAircraft.LiftCoeffModel = @(inputs) LiftCoeffModel(inputs);
    myAircraft.CrossforceCoeffModel = @(inputs) CrossforceCoeffModel(inputs);
    myAircraft.RollCoeffModel = @(inputs) RollCoeffModel(inputs);
    myAircraft.PitchCoeffModel = @(inputs) PitchCoeffModel(inputs);
    myAircraft.YawCoeffModel = @(inputs) YawCoeffModel(inputs);

    save(strcat(aircraftName, '.mat'), '-struct', 'myAircraft')

end