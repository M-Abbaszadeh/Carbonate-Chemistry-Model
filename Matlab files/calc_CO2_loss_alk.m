%author: Riley Doyle
% date: 06-09-2020
% file name: calc_loss_kL_alk.m
% output: Calculate loss with different kL values and alkalinities

function r_kL_alk = calc_CO2_loss_alk (pK1, pK2, Kh, PCO2, alkin, alkend, delalk, kLain, kLaend, delkLa, pH)
m_steps = (kLaend-kLain)/delkLa;
kLa = kLain;

n_steps = (alkend - alkin)/delalk;

r_kL_alk = zeros(n_steps+1, m_steps + 1);

for p = 1:m_steps+1
    
    alk = alkin;
    
    for c = 1:n_steps+1
    
        %calculate alphas
        alpha0 = calc_alpha0(pH, pK1, pK2);
        alpha1 = calc_alpha1(pH, pK1, pK2);
        alpha2 = calc_alpha2(pH, pK1, pK2);
        CO2sat = PCO2*Kh*1000;
        
        %calculate H+ and OH and CT
        H = 10^(-pH);
        OH = 10^(-(14-pH));
        bt = (1/(alpha1 + (2.*alpha2)));
        tp = (alk - OH + H);
        CT = tp * bt;
        
        %calculate dissolved CO2 concentration
        H2CO3 = alpha0*CT;
        HCO3 = alpha1*CT;
        CO3 = alpha2*CT;
        
        %calculate loss of CO2 per hour
        loss = kLa*(H2CO3 - CO2sat)*44; %g CO2 per day 

        
        r_kL_alk(c,1)= alk; %record alk
        r_kL_alk(c,1+p)= loss; %record loss
        alk = alk + delalk;  %increase alk
    end 
   kLa = kLa + delkLa;
end

