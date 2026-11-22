import math
g=9.81
L={'T1':('chair',880,240,1200),'T2':('surface',540,140,1000),'T3':('surface',410,150,600),'T4':('surface',230,30,350)}
Prated={'low':{'T1':110,'T2':40,'T3':24,'T4':4},'base':{'T1':150,'T2':50,'T3':30,'T4':5.5},'high':{'T1':160,'T2':60,'T3':36,'T4':9}}
phi={'low':{'chair':0.30,'surface':0.20},'base':{'chair':0.375,'surface':0.30},'high':{'chair':0.45,'surface':0.40}}
eta={'low':0.95,'base':0.90,'high':0.85}
mu={'low':0.06,'base':0.12,'high':0.12}
mass={'low':75,'base':80,'high':85}
S={'low':5000,'base':10700,'high':26000}
D={'low':60,'base':80,'high':100}
rides={'low':6,'base':8,'high':12}
w=0.35; kwe=3.0
# hourly shape: Szlosarek Table5 vehicles/84 for 09..16, 08-09 = half of 09-10 (assumed)
sz=[80,69,59,26,35,35,26]
shape_raw=[0]*24
shape_raw[8]=0.5*sz[0]/84
for i,x in enumerate(sz): shape_raw[9+i]=x/84
# base hours 08-16 ; low 09-16 ; high 08-17 (extra hour = last value)
def shape(sc):
    s=shape_raw[:]
    if sc=='low': s[8]=0
    if sc=='high': s[16]=sz[-1]/84*0.5
    tot=sum(s); return [x/tot for x in s]
Qtot=sum(v[3] for v in L.values())
for sc in ['low','base','high']:
    sh=shape(sc); hours=sum(1 for x in sh if x>0)
    nwd=S[sc]/(D[sc]*(1-w+w*kwe)); nwe=kwe*nwd
    out={}
    Etot=0; Pday={}
    for daytype,n in [('wd',nwd),('we',nwe)]:
        Rday=n*rides[sc]
        P=[0]*24; U=[0]*24
        for name,(t,Ll,H,Q) in L.items():
            Lh=math.sqrt(Ll*Ll-H*H)
            Heff=H+(mu[sc]*Lh if t=='surface' else 0)
            e=mass[sc]*g*Heff/(eta[sc]*3.6e6)
            P0=phi[sc][t]*Prated[sc][name]
            Ri=Rday*Q/Qtot
            for h in range(24):
                if sh[h]>0:
                    u=min(1,Ri*sh[h]/Q)
                    P[h]+=min(Prated[sc][name],P0+u*Q*e)
        Pday[daytype]=P
        out[daytype]=(n,Rday,sum(P))
    Eseason=D[sc]*((1-w)*sum(Pday['wd'])+w*sum(Pday['we']))
    Prt=sum(Prated[sc].values())
    print(f"\n=== {sc}: Prated_total={Prt} kW hours={hours} skiers wd={out['wd'][0]:.0f} we={out['we'][0]:.0f}")
    print(f" daily kWh wd={out['wd'][2]:.0f} we={out['we'][2]:.0f}; season MWh={Eseason/1000:.1f}; kWh/skierday={Eseason/S[sc]:.2f}; kWh/ride={Eseason/(S[sc]*rides[sc]):.3f}")
    P0tot=sum(phi[sc][L[n][0]]*Prated[sc][n] for n in L)
    print(f" P0 total={P0tot:.1f} kW; no-load energy share={P0tot*hours*D[sc]/Eseason:.2f}")
    print(" load factor (rides/capacity) wd=%.3f we=%.3f"%(out['wd'][1]/(Qtot*hours),out['we'][1]/(Qtot*hours)))
    print(" P wd:",[round(x,1) for x in Pday['wd']])
    print(" P we:",[round(x,1) for x in Pday['we']])
    print(" P/Prated wd:",[round(x/Prt,3) for x in Pday['wd']])
    print(" P/Prated we:",[round(x/Prt,3) for x in Pday['we']])
    # passenger loading u (aggregate) per hour
    for daytype,n in [('wd',nwd),('we',nwe)]:
        print(f" u {daytype}:",[round(n*rides[sc]*s/Qtot,3) for s in sh])
print("shape base:",[round(x,3) for x in shape('base')])
# Engineering cross-check: Szlosarek gondola
print("Szlosarek Wh/(pers m):",3044e3/9055/671.65, " theoretical 80kg:",80*9.81/3600)
print("\n--- peak (design) day, base params, u = Szlosarek raw capacity fractions")
sc='base'; uh=[0]*24; uh[8]=0.5*80/84
for i,x in enumerate(sz): uh[9+i]=x/84
P=[0]*24
for name,(t,Ll,H,Q) in L.items():
    Lh=math.sqrt(Ll*Ll-H*H); Heff=H+(mu[sc]*Lh if t=='surface' else 0)
    e=mass[sc]*g*Heff/(eta[sc]*3.6e6); P0=phi[sc][t]*Prated[sc][name]
    print(name, f"e_ride={e:.4f} kWh P0={P0:.1f} Pfull_uncapped={P0+Q*e:.1f} rated={Prated[sc][name]}")
    for h in range(24):
        if uh[h]>0: P[h]+=min(Prated[sc][name],P0+uh[h]*Q*e)
print("u peak:",[round(x,3) for x in uh]); print("P peak:",[round(x,1) for x in P], "daily kWh",round(sum(P)))
print("rides peak day:", round(sum(uh)*3150))
