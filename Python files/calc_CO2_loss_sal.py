#author: Riley Doyle
#date: 7/29/20
#file: calc_CO2_loss_sal
#status: working

import numpy as np
import matplotlib.pyplot as plt
from calc_Ks import *
from calc_alphas import *
from calc_density import *

def calc_CO2_loss_sal (pK1, pK2, alk, d, PCO2, pHin, pHend, delpH, kLa, T, Sin, Send, delS):
    L = np.array(['-', '--', '-.', ':', '--'])
    pH = np.arange(pHin, pHend, delpH)
    Ssteps = np.arange(Sin, Send, delS)
    nSsteps = len(Ssteps)
    y = np.zeros((nSsteps, len(pH)))
    i = 0
    for c in Ssteps:
        Tc = 20; #celcius
        P = 10; #(dbar)
        t = Tc*1.00024;
        p = P/10;
        den = calc_density(c, t, p); #(kg/m3)
        K1 = calc_K1(T,c)*(den/1000) #mol/L
        pK1 = -np.log10(K1)
        K2 = calc_K2(T,c)*(den/1000) #mol/L
        pK2 = -np.log10(K2)
        Kh = calc_Kh(T,c)*(den/1000) #mol/L/atm
        alpha0 = calc_alpha0(pH, pK1, pK2)
        alpha1 = calc_alpha1(pH, pK1, pK2)
        alpha2 = calc_alpha2(pH, pK1, pK2)
        CO2sat = PCO2*Kh*1000
            
        H = 10**(-pH)
        OH = 10**(-(14-pH))
        bt = (1/(alpha1 + (2*alpha2)))
        tp = (alk - OH + H)
        CT = tp * bt
            
        H2CO3 = alpha0*CT
        y[i,:] = kLa*(H2CO3 - CO2sat)*24*44
        y = y*d
        plt.plot(pH, y[i,:].T, linestyle=L[i])
        i += 1