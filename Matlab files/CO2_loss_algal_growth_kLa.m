% Author: Riley Doyle
% Date: June 25 2020
%Dependent function: rates, calc_K1, calc_K2, calc_Kh, calc_alpha0,
    %calc_alpha1, calc_alpha2
%Inputs: pH, kLa, y_2, y_1, k1, k2, k3, k4, Csat, pk1, pk2, d, alk0, r_algae
%Outputs: CO2 losses to the atmospher vs. time, CO2 requirements vs. time
    %with different kLa values 

%delete all figures and variables in the workspace
clear
close all

%define variables as global, a variable that is shared by the function and
%workspace
global k1 k2 k3 k4 

%Environmental conditions
T = 20 + 273.15; %temp in Kelvins
S = 35; %(salinity in g/kg)
PCO2 = 0.000416; % (atm)
Tc = 20;
P = 10; %(dbar)
t = Tc*1.00024;
p = P/10;
den = calc_density(S, t, p); %(kg/m3)

%Pond characteristics
d = 0.15; %(m) depth of pond

%Stoicheometric constants for algal growth
y_2 = 0.1695; % (g bicarbonate as CO2 per g algae) from stoicheometry
y_1 = 1.714;  %(g CO2 per g algae) from stoicheometry


Kh = calc_Kh(T, S)*(den/1000); %(mole/L/atm)

%carbonic acid/bicarbonate equilibrium
K_1 = calc_K1(T, S)*(den/1000); %(mol/L)

pK1=-log10(K_1); 

%bicarbonate/carbonate equlibrium
K_2 = calc_K2(T, S)*(den/1000); %(mol/L)

pK2= -log10(K_2);

Csat = PCO2*Kh*44*1000;  %(g/m3)

%Assumptions & initial conditions in moles per sample volume
alk0 = 2.5;  %(eq/m3 or meq/L)
r_algae = 10;  % growth rate (g/m2/day); 
pH= 8; 

%Calculate alphas 
alpha0 = calc_alpha0(pH,pK1, pK2); %no units
alpha1 = calc_alpha1(pH,pK1, pK2); %no units
alpha2 = calc_alpha2(pH,pK1, pK2); %no units

%Calculate [H+] and [OH-]
OH=10^-(14-pH)*10^3; %(moles/m3)
H=(10^(-pH))*10^3;  %(moles/m3)
        
%Initial Conditions       
Caq0=((alk0 - OH + H)*alpha0/(alpha1+2*alpha2))*44; %(g/m3)
Cin0 = 0; %(g/m2)
Closs0 = 0; %(g/m2)

% create array of times for output
time = linspace(0, 4);  %4 days

%Set initial conditions
%Caq = dissolved concentation
%Cin = CO2 supply
%Closs = CO2 losses
x0 = [Caq0; Cin0; Closs0];

delkLa = 2.5; %(1/hr)
kLa = .5; %(1/hr)
C = {'r','b'};
iterCount = 0;

while kLa <= 3
iterCount = iterCount + 1;
%Solve ODEs with the ode15s solver
%returns output arrays of tout and x
%rates is the ODE system, time is the x values, x0 is the initial conditions
% rate constants for odes
%delivery requirements for the algal pond
%rate of Caq removed due to alkalinity consumption by algae Eq(15)
k1 = y_2*r_algae*alpha0/(alpha1+2*alpha2);
% k2-k3 = C needed to be delivered to satisfy diffusion out of pond Eq(19)
k2 = kLa*24*d; %(m/day) 
k3 = kLa*Csat*24*d; %k2*x-k3 = rate of C loss due to the atmosphere, (g/m2*day)
k4 = (y_1 + y_2*(1 - alpha1 - 2*alpha2))*r_algae; 
[tout, x] = ode15s(@rates, time, x0);
xmass = x;

CO2aq = xmass(:,1);
xmass(:,1) = [];
CO2req = xmass(:,1);
xmass(:,1) = [];
CO2loss = xmass(:,1);
xmass(:,1) = [];
%modify plot and plot only CO2 loss and delivery requirements
figure(1)
plot(tout, CO2req, 'color', C{iterCount}) 
hold on
plot(tout, CO2loss,'color', C{iterCount}, 'LineStyle', '--') 
hold on 
kLa = kLa + delkLa;
end
hold on

figure(1)
xlabel('Time (day)')
ylabel('CO_2 (g m^{-2})')
legend('CO_2 supply for kLa = 0.5 hr^{-1}', 'CO_2 loss for kLa = 0.5 hr^{-1}',...
    'CO_2 supply for kLa = 3 hr^{-1}', 'CO_2 loss for kLa = 3 hr^{-1}')

