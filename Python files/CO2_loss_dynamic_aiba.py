#author: Riley Doyle
#date: 8/12/20
#file: CO2_loss_dynamic_aiba
#status: WORKING

#modified aiba model

from calc_Ks import *
from calc_alphas import *
from calc_density import *
import numpy as np
from scipy.integrate import odeint
import matplotlib.pyplot as plt

T = 20 + 273.15 #kelvins
S = 35 #g/kg
Tc = 20
P = 10 #(dbar)
t = Tc*1.00024
p = P/10
den = calc_density(S, t, p) #(kg/m3)
PCO2 = 0.000416 #atm
d = 0.15 #m
I = 100 #W/m2
kd = 0.3 #1/day
K = 120 #g/m2

kLa = 3 #1/hr
y1 = 1.714 #g CO2 per g algae
y2 = 0.1695 #g HCO3 as CO2 per g algae

Kh = calc_Kh(T,S)*(den/1000) #mol/L/atm
K1 = calc_K1(T, S)*(den/1000) #mol/L
pK1 = - np.log10(K1)
K2 = calc_K2(T, S)*(den/1000) #mol/L
pK2 = - np.log10(K2)

Csat = PCO2*Kh*44*1000 #g/m3
alk0 = 2.5 #eq/m3
pH = 8

alpha0 = calc_alpha0(pH, pK1, pK2)
alpha1 = calc_alpha1(pH, pK1, pK2)
alpha2 = calc_alpha2(pH, pK1, pK2)

OH = 10**-(14-pH)*(10**3)
H = (10**(-pH))*(10**3)

k1 = alpha0/(alpha1 + 2*alpha2)*y2
k2 = (kLa*d*24)
k3 = (kLa*d*24)*Csat
k4 = (y1 + y2)
k5 = y2*(alpha1 + 2*alpha2)
K1 = (200.1/24)
K2 = (0.1110/24)
u2 = (I)/(K1 + K2*(I**2))
def rate_kinetics(x,t):
    X = x[0]
    P = x[1]
    Caq = x[2]
    Cdel = x[3]
    Closs = x[4]
    dXdt = (u2-kd)*(1-(X/K))*X
    dPdt = dXdt
    dCaqdt = -k1*P
    dCdeldt = ((k2 *Caq) - k3) + (k4*P - k5*P)
    dClossdt = (k2 *Caq) - k3
    return [dXdt, dPdt, dCaqdt, dCdeldt, dClossdt]
        
Caq0 = ((alk0 - OH + H)*alpha0/(alpha1 + 2*alpha2))*44 #g/m3
Cin0 = 0
Closs0 = 0 
X0 = 0.04
P0 = 0
x0 = [X0, P0, Caq0, Cin0, Closs0]
t = np.linspace(0,4,100)
x = odeint(rate_kinetics, x0, t)

X = x[:,0]
P = x[:, 1]
Caq = x[:,2]
Cdel = x[:,3]
Closs = x[:,4]


plt.xlabel('time (days)')
plt.ylabel('CO$_2$ (g/m$^2$)')
plt.plot(t,Cdel)
plt.plot(t, Closs)
plt.legend(['CO$_2$ supply required', 'CO$_2$ loss to atmosphere'], frameon=False)
plt.axis([0, 4, 0, 40])
plt.show()