close all; clear all; clc;

load TP_TAKE_OFF

Altitude_Vector = nan(1,4);
for i = 1:4
    Altitude_Vector(i) = EngineDatabaseTP_TO.Altitude(i*13);
end

Mach_Vector = EngineDatabaseTP_TO.Mach(1:13);

Thrust_Ratio_Vector = EngineDatabaseTP_TO.TT0(1:end);

TSFC_Vector = EngineDatabaseTP_TO.TSFC(1:end);

n_Mach = 52;
n_Mach_f = n_Mach;
n_Altitude_f = 1000;

%-----Thrust Ratio-----

Thrust_Ratio_Interp_TO = nan(length(Altitude_Vector),n_Mach);
p = nan(1,length(Altitude_Vector));
figure(1)
for i = 0:length(Altitude_Vector)-1
    pp = csaps(Mach_Vector,Thrust_Ratio_Vector(i*13+1:i*13+13),0.999999);
    Thrust_Ratio_Interp_TO(i+1,:) = ...
        fnval(linspace(Mach_Vector(1),Mach_Vector(end),n_Mach),pp);
    plot(Mach_Vector,Thrust_Ratio_Vector(i*13+1:i*13+13),'o'); hold on;
    p(i+1) = plot(linspace(Mach_Vector(1),Mach_Vector(end),n_Mach),...
        Thrust_Ratio_Interp_TO(i+1,:));
    %title('T/T_0 at different altitude');
end
xlabel('M'); ylabel('T/T_0');
set(gca,'FontSize',18)
legend(p,'h = 0 ft','h = 5000 ft','h = 10000 ft',...
    'h = 15000 ft','location','northeast');

[MACH_Vector,ALTITUDE_Vector] = meshgrid(linspace(Mach_Vector(1),...
    Mach_Vector(end),n_Mach),Altitude_Vector);
Mach_Vector_f = linspace(Mach_Vector(1),Mach_Vector(end),n_Mach_f);
Altitude_Vector_f = linspace(Altitude_Vector(1),...
    Altitude_Vector(end),n_Altitude_f);
[MACH_Vector_f,ALTITUDE_Vector_f] = ...
    meshgrid(Mach_Vector_f,Altitude_Vector_f);
THRUST_RATIO_f = interp2(MACH_Vector,ALTITUDE_Vector,...
    Thrust_Ratio_Interp_TO,MACH_Vector_f,ALTITUDE_Vector_f,'spline');
figure(2)
mesh(MACH_Vector_f,ALTITUDE_Vector_f,THRUST_RATIO_f);
xlabel('M'); ylabel('h (ft)'); zlabel('T/T_0');
set(gca,'FontSize',18)

%-----TSFC-----

TSFC_Interp_TO = nan(length(Altitude_Vector),n_Mach);
figure(3)
for i = 0:length(Altitude_Vector)-1
    pp = csaps(Mach_Vector,TSFC_Vector(i*13+1:i*13+13),0.999999);
    TSFC_Interp_TO(i+1,:) = ...
        fnval(linspace(Mach_Vector(1),Mach_Vector(end),n_Mach),pp);
    plot(Mach_Vector,TSFC_Vector(i*13+1:i*13+13),'o'); hold on;
    p(i+1) = plot(linspace(Mach_Vector(1),Mach_Vector(end),n_Mach),...
        TSFC_Interp_TO(i+1,:));
    %title('TSFC at different altitude');
end
xlabel('M'); ylabel('TSFC (lb/(lb*hr)');
set(gca,'FontSize',18)
legend(p,'h = 0 ft','h = 5000 ft','h = 10000 ft',...
    'h = 15000 ft','location','northwest');

TSFC_f = interp2(MACH_Vector,ALTITUDE_Vector,...
    TSFC_Interp_TO,MACH_Vector_f,ALTITUDE_Vector_f,'spline');
figure(4)
mesh(MACH_Vector_f,ALTITUDE_Vector_f,TSFC_f);
xlabel('M'); ylabel('h (ft)'); zlabel('TSFC lb/(lb*hr)');
set(gca,'FontSize',18)

%save 'Data_TP_TO' Thrust_Ratio_Interp_TO TSFC_Interp_TO