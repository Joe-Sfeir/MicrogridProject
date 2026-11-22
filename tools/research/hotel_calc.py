import json,sys
prof=json.load(open(sys.argv[1]))
keys=25
months=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
days=[31,28,31,30,31,30,31,31,30,31,30,31]
base_occ=[0.70,0.75,0.60,0.32,0.33,0.43,0.60,0.60,0.38,0.32,0.24,0.50]
winter={0,1,2,3,9,10,11}  # Oct-Apr use winter profile
occ_ann=sum(o*d for o,d in zip(base_occ,days))/365
print('base annual occupancy',round(occ_ann,3))
scen={'low':0.643,'base':1.0,'high':1.25}  # low = 38.6/60 (Jul-2026 mountain weekly avg vs 2025 summer anchor); high = assumed +25%, capped
occ_ref=0.75
H={'low':dict(apk=25,eui=86,fv=0.15),'base':dict(apk=49.8,eui=105,fv=0.25),'high':dict(apk=77.1,eui=130,fv=0.35)}
R={'low':dict(area=3*232.3,eui=65.7,fv=0.54),'base':dict(area=3*511,eui=90,fv=0.54),'high':dict(area=3*511,eui=270,fv=0.54)}
def daysplit(o):
    wd=o*7/9; we=min(1.0,2*wd)
    if we==1.0: wd=(7*o-2)/5
    return wd,we
out={}
for s in ('low','base','high'):
    occ=[min(0.95,o*scen[s]) for o in base_occ]
    oa=sum(o*d for o,d in zip(occ,days))/365
    res={}
    for typ,P in (('hotel',H[s]),('rest',R[s])):
        area=P['apk']*keys if typ=='hotel' else P['area']
        Eref=area*P['eui']/1000  # MWh/yr at reference activity
        fv=P['fv']; ff=1-fv
        # daily energy (MWh/day) by month & day type
        ann=0; peak=0; monthly=[]
        for m in range(12):
            wd,we=daysplit(occ[m])
            season='winter' if m in winter else 'summer'
            em=0
            for o,lbl,n in ((wd,'weekday',days[m]*5/7),(we,'weekend',days[m]*2/7)):
                daily=Eref/365*(ff+fv*o/occ_ref)
                em+=daily*n
                pk=daily*1000*max(prof[f'{typ}_{season}_{lbl}'])
                peak=max(peak,pk)
            monthly.append(em); ann+=em
        res[typ]=dict(area=round(area),Eref=round(Eref,1),annual=round(ann,1),peak_kW=round(peak,1),itp5000=round(ann*1000/5000,1),mean_kW=round(ann*1000/8760,1),monthly=[round(x,2) for x in monthly])
    res['occ_annual']=round(oa,3); res['occ']=[round(o,3) for o in occ]
    out[s]=res
    print(s,json.dumps(res))
# per occupied room-night (base)
b=out['base']; rn=keys*365*b['occ_annual']; print('base room-nights',round(rn),'kWh/occ room-night',round(b['hotel']['annual']*1000/rn,1))
for s in out: 
    rn=keys*365*out[s]['occ_annual']; print(s,'kWh/occ-room-night',round(out[s]['hotel']['annual']*1000/rn,1),'kWh/room-yr',round(out[s]['hotel']['annual']*1000/keys))
