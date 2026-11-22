import math
g=9.81
lifts={ # name: type, L, H, Q, v
 'T1':('chair',880,240,1200,2.1),
 'T2':('surface',540,140,1000,2.5),
 'T3':('surface',410,150,600,2.5),
 'T4':('surface',230,30,350,1.5)}
k=80*g/3.6e6  # kW per (m * p/h) for 80 kg
print("k=",k)
# benchmarks Viesi Table 1
bench={'Nube dArgento 2CLF':(150,875,1200,100),'Vagliana 2CLF':(185,786,1028,100),'Miramonti 2CLF':(183,466,1125,110),
'Fevri 3CLF':(368,1057,1500,260),'Pancugolo 4CLF':(212,447,1600,131),'Larici J-bar':(78,394,720,20.8)}
for n,(H,L,Q,P) in bench.items():
    Lh=math.sqrt(L*L-H*H); Pl=k*H*Q; Pf=k*(H+0.12*Lh)*Q
    print(f"{n}: mgHQ={Pl:.1f} kW ratio={P/Pl:.2f}; with mu0.12 Heff={H+0.12*Lh:.0f} -> {Pf:.1f} ratio {P/Pf:.2f}; kW/(km*kpph)={P/(L*Q)*1e6:.1f}")
for n,(t,L,H,Q,v) in lifts.items():
    Lh=math.sqrt(L*L-H*H)
    print(n, f"Lh={Lh:.0f} grade={H/Lh*100:.0f}% mgHQ={k*H*Q:.1f} Heff(0.12)={H+0.12*Lh:.0f} -> {k*(H+0.12*Lh)*Q:.1f}  Heff(0.06)->{k*(H+0.06*Lh)*Q:.1f}  L*Q bench {L*Q*64.5e-6:.1f}-{L*Q*112e-6:.1f}")
