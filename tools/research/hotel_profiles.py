import json, math, sys
d=json.load(open(sys.argv[1]))['schedules']
def get(name, dt):
    for s in d:
        if s['name']==name and dt in s['day_types'].split('|') and s['type']=='Hourly':
            return s['values']
    for s in d:
        if s['name']==name and 'Default' in s['day_types'].split('|'):
            v=s['values']; return v*24 if len(v)==1 else v
    raise KeyError(name)
flat=[1.0]*24
# sunrise/sunset (NOAA approx) for Faqra 33.985N 35.811E
def sun(doy, lat=33.985, lon=35.811, tz=2):
    g=2*math.pi/365*(doy-1)
    eqt=229.18*(0.000075+0.001868*math.cos(g)-0.032077*math.sin(g)-0.014615*math.cos(2*g)-0.040849*math.sin(2*g))
    dec=0.006918-0.399912*math.cos(g)+0.070257*math.sin(g)-0.006758*math.cos(2*g)+0.000907*math.sin(2*g)-0.002697*math.cos(3*g)+0.00148*math.sin(3*g)
    ha=math.degrees(math.acos(math.cos(math.radians(90.833))/(math.cos(math.radians(lat))*math.cos(dec))-math.tan(math.radians(lat))*math.tan(dec)))
    rise=720-4*(lon+ha)-eqt; sett=720-4*(lon-ha)-eqt
    return rise/60+tz, sett/60+tz
def ext(rise,sett):
    # fraction of each clock hour h (h..h+1) in darkness
    out=[]
    for h in range(24):
        dark=max(0,min(h+1,rise)-h)+max(0,h+1-max(h,sett))
        out.append(min(1,dark))
    return out
jan=sun(15,tz=2); jul=sun(196,tz=3)
print('Jan sunrise/sunset local',[round(x,2) for x in jan],' Jul (EEST)',[round(x,2) for x in jul])
def comp(parts):
    tot=[0]*24
    W=sum(w for w,_ in parts)
    for w,sch in parts:
        s=sum(sch)
        for h in range(24): tot[h]+=w/W*sch[h]/s
    return tot
def show(lbl,p):
    print(lbl,' '.join(f'{x:.4f}' for x in p),'| sum',round(sum(p),4),'| peak/mean',round(max(p)*24,3),'| min/mean',round(min(p)*24,3),'| peak hr',p.index(max(p)))
res={}
for season,(r,s) in (('winter',jan),('summer',jul)):
    e=ext(r,s)
    for dt,lbl in (('Wkdy','weekday'),('Default','weekend')):
        L=get('HotelSmall BLDG_LIGHT_GUESTROOM_SCH_2010',dt)
        Eq=get('HotelSmall GuestRoom_Eqp_Sch_Base',dt)
        Lob=get('HotelSmall Lobby_Eqp_Sch',dt)
        # CBECS 2018 E5 lodging (bn kWh): vent 25, lighting 15 (12 interior/3 exterior assumed 80/20), refrig 8, office+computing 3, other 21
        parts=[(25,flat),(15*0.8,L),(15*0.2,e),(8,flat),(3,Lob),(21,Eq)]
        p=comp(parts); res[f'hotel_{season}_{lbl}']=p; show(f'HOTEL {season} {lbl}:',p)
for season in ('winter','summer'):
    for dt,lbl in (('Wkdy','weekday'),('Sat','weekend')):
        Ld=get('RestaurantSitDown BLDG_LIGHT_DINING_SCH_2013',dt)
        Eq=get('RestaurantSitDown BLDG_EQUIP_SCH',dt)
        hv=get('RestaurantSitDown HVACOperationSchd',dt)
        oc=get('RestaurantSitDown BLDG_OCC_SCH',dt)
        # CBECS 2018 E5 food service (bn kWh): refrig 16, vent 7, lighting 4, other 8, cooling 7 (summer only)
        parts=[(16,flat),(7,hv),(4,Ld),(8,Eq)]
        if season=='summer': parts.append((7,oc))
        p=comp(parts); res[f'rest_{season}_{lbl}']=p; show(f'REST {season} {lbl}:',p)
json.dump(res,open(sys.argv[2],'w'),indent=1)
