"""Single-line diagram of the Faqra Club PV-BESS microgrid (SVG, PNG, PDF).

Design basis: base-case sizes from results/ (983 kWp PV, 2,622 kWh / 790 kW BESS, 519 kW peak), the
existing diesel sets, islanding at the 20 kV point of common coupling, and a split of the club loads
into an essential (critical) and a sheddable part. New equipment is drawn in blue, existing or
assumed-existing equipment in grey. Run:  python3 tools/make_sld.py
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "paper" / "figs"
OUT.mkdir(parents=True, exist_ok=True)

W, H = 1800, 1230
NEW, OLD, CTRL, INK, MUTED = "#1f5fb4", "#6b6a66", "#c2410c", "#111111", "#55534e"
E = []  # svg elements


def add(s):
    E.append(s)


def line(x1, y1, x2, y2, c=INK, w=2, dash=None):
    d = f' stroke-dasharray="{dash}"' if dash else ""
    add(f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{c}" stroke-width="{w}"{d}/>')


def text(x, y, s, size=13, c=INK, anchor="start", weight="normal", italic=False):
    st = ' font-style="italic"' if italic else ""
    for k, part in enumerate(s.split("\n")):
        add(f'<text x="{x}" y="{y + k * (size + 3)}" font-size="{size}" fill="{c}" text-anchor="{anchor}" '
            f'font-weight="{weight}"{st} stroke="white" stroke-width="3.5" paint-order="stroke">{part}</text>')


def bus(x1, x2, y, label, c=INK):
    line(x1, y, x2, y, c, 6)
    text(x1, y - 10, label, 13, c, weight="bold")


def breaker(x, y, label="", c=INK, side="right"):
    """Circuit breaker on a vertical conductor (square)."""
    add(f'<rect x="{x - 8}" y="{y - 8}" width="16" height="16" fill="white" stroke="{c}" stroke-width="2"/>')
    if label:
        dx = 14 if side == "right" else -14
        text(x + dx, y + 4, label, 11, c, "start" if side == "right" else "end")


def switch(x, y, label="", c=INK):
    """Disconnector / load-break switch (open blade drawn closed)."""
    line(x, y - 10, x + 9, y + 8, c, 2)
    add(f'<circle cx="{x}" cy="{y + 10}" r="2.5" fill="{c}"/>')
    if label:
        text(x + 14, y + 4, label, 11, c)


def transformer(x, y, label, c=INK):
    add(f'<circle cx="{x}" cy="{y - 10}" r="15" fill="none" stroke="{c}" stroke-width="2"/>')
    add(f'<circle cx="{x}" cy="{y + 10}" r="15" fill="none" stroke="{c}" stroke-width="2"/>')
    text(x + 22, y - 4, label, 11, c)


def generator(x, y, label, c=OLD):
    add(f'<circle cx="{x}" cy="{y}" r="22" fill="white" stroke="{c}" stroke-width="2"/>')
    text(x, y + 1, "G", 15, c, "middle", "bold")
    text(x, y + 15, "3~", 10, c, "middle")
    text(x, y + 38, label, 11, c, "middle")


def inverter(x, y, label, c=NEW, w=56, h=40):
    add(f'<rect x="{x - w / 2}" y="{y - h / 2}" width="{w}" height="{h}" fill="white" stroke="{c}" stroke-width="2"/>')
    line(x - w / 2, y + h / 2, x + w / 2, y - h / 2, c, 1.5)
    text(x - w / 2 + 6, y - 5, "=", 13, c)
    text(x + w / 2 - 14, y + 15, "~", 13, c)
    if label:
        text(x + w / 2 + 8, y + 4, label, 11, c)


def battery(x, y, label, c=NEW):
    for k in range(3):
        yy = y - 12 + k * 12
        line(x - 18, yy, x + 18, yy, c, 3)
        line(x - 9, yy + 5, x + 9, yy + 5, c, 2)
    text(x + 26, y, label, 11, c)


def pv(x, y, label, c=NEW):
    add(f'<rect x="{x - 26}" y="{y - 18}" width="52" height="36" fill="white" stroke="{c}" stroke-width="2"/>')
    for k in (1, 2):
        line(x - 26 + k * 52 / 3, y - 18, x - 26 + k * 52 / 3, y + 18, c, 1)
    line(x - 26, y, x + 26, y, c, 1)
    text(x + 34, y + 4, label, 11, c)


def load(x, y, label, c=INK, crit=False):
    fill = "#111111" if crit else "white"
    add(f'<polygon points="{x - 8},{y} {x + 8},{y} {x},{y + 14}" fill="{fill}" stroke="{c}" stroke-width="2"/>')
    text(x, y + 30, label, 10.5, c, "middle")


def box(x, y, w, h, c, title=None, lines=(), dash=None, fill="white", size=11):
    d = f' stroke-dasharray="{dash}"' if dash else ""
    add(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{fill}" stroke="{c}" stroke-width="1.6"{d} rx="4"/>')
    yy = y + 17
    if title:
        text(x + 8, yy, title, size + 1, c, weight="bold")
        yy += size + 7
    for s in lines:
        text(x + 8, yy, s, size, INK)
        yy += size + 4


def tag(x, y):
    """Marks a device controlled by the micro-grid controller."""
    add(f'<circle cx="{x}" cy="{y}" r="8" fill="white" stroke="{CTRL}" stroke-width="1.6"/>')
    add(f'<text x="{x}" y="{y + 3.5}" font-size="9" fill="{CTRL}" text-anchor="middle" font-weight="bold">C</text>')


def meter(x, y, label):
    add(f'<circle cx="{x}" cy="{y}" r="13" fill="white" stroke="{INK}" stroke-width="2"/>')
    text(x, y + 4, "kWh", 8.5, INK, "middle", "bold")
    text(x + 20, y + 4, label, 11, INK)


# ------------------------------------------------------------------------------------ title
text(30, 38, "Faqra Club PV-BESS micro-grid: single-line diagram (base-case design)", 20, INK, weight="bold")
text(30, 60, "20 kV point of common coupling; AC-coupled PV, battery and existing diesel sets on a common 400 V "
     "generation bus; essential and sheddable loads separated", 12.5, MUTED)

# ----------------------------------------------------------------------- utility and PCC (top centre)
X0 = 900
text(X0, 92, "EDL 20 kV overhead feeder \"Faqra\" (Faitroun S/S)", 13, INK, "middle", "bold")
line(X0, 100, X0, 330)
add(f'<polygon points="{X0 - 9},{100} {X0 + 9},{100} {X0},{112}" fill="{INK}"/>')
switch(X0, 135, "Q0  20 kV load-break switch (EDL)")
meter(X0 + 0, 180, "EDL tariff meter, MV CT/VT (existing)")
breaker(X0, 232, "52-PCC  20 kV CB, 630 A (new)", NEW, side="left")
tag(X0 + 22, 222)
line(X0 - 26, 248, X0 + 26, 248, MUTED, 1, "4,3")
text(X0 - 30, 262, "island boundary", 10.5, MUTED, "end", italic=True)
# relay
box(X0 + 290, 190, 330, 132, NEW, "Intertie protection relay (PCC)",
    ["50/51, 50N/51N  overcurrent / earth fault",
     "67  directional overcurrent",
     "27/59, 81O/U  voltage and frequency",
     "81R (ROCOF), loss-of-mains trip",
     "25  sync-check for reconnection to EDL",
     "32  reverse power (no export in base case)"])
line(X0 + 8, 240, X0 + 290, 240, NEW, 1.3, "5,4")
meter(X0, 292, "Club revenue / power-quality meter")
line(X0, 305, X0, 330)

# ----------------------------------------------------------------------------- 20 kV club bus
YMV = 345
bus(250, 1560, YMV, "Club 20 kV switchgear (RMU, existing; new panel for F1)", INK)

# feeder x positions
XF1, XF2, XF3, XF4 = 420, 860, 1140, 1420

# ------------------------------------------------------------------ F1: generation transformer
line(XF1, YMV, XF1, 470)
breaker(XF1, 380, "F1  20 kV CB (new)", NEW)
transformer(XF1, 430, "TX-G  20/0.4 kV\n1,000 kVA, Dyn11\nuk 6% (new)", NEW)
YG = 510
line(XF1, 445, XF1, YG)
breaker(XF1, 478, "ACB 1,600 A, LSIG", NEW)
bus(90, 760, YG, "400 V generation bus  MSB-G (new)", NEW)

# PV branch
XPV = 160
line(XPV, YG, XPV, 700, NEW)
breaker(XPV, 540, "MCCB 1,250 A", NEW)
box(XPV - 62, 562, 124, 34, NEW, None, ["PV AC combiner board"], fill="#f3f7fd")
for k in range(4):
    xi = XPV - 60 + k * 40
    line(xi, 596, xi, 640, NEW, 1.5)
line(XPV - 60, 640, XPV + 60, 640, NEW, 1.5)
inverter(XPV, 670, "", NEW)
text(XPV - 70, 674, "8 x", 12, NEW, "end", "bold")
text(XPV + 36, 662, "string inverters\n8 x 100 kVA\nIEC 62116 anti-islanding", 10.5, NEW)
line(XPV, 690, XPV, 740, NEW)
add(f'<rect x="{XPV - 6}" y="{712}" width="12" height="12" fill="white" stroke="{NEW}" stroke-width="2"/>')
text(XPV + 12, 722, "DC isolators, string fuses, SPD type 2", 10.5, NEW)
pv(XPV, 765, "", NEW)
text(XPV - 66, 806, "PV array 983 kWp DC (about 1,790 x 550 Wp)\ntilt 30 deg, south; DC/AC 1.23\nraised >= 1.2 m above ground (snow)", 10.5, NEW)

# BESS branch
XB = 430
line(XB, YG, XB, 760, NEW)
breaker(XB, 540, "ACB 1,250 A", NEW)
inverter(XB, 600, "PCS  2 x 400 kVA\nbidirectional, grid-forming\n(master in island mode)", NEW, 60, 44)
line(XB, 622, XB, 700, NEW)
add(f'<rect x="{XB - 6}" y="{650}" width="12" height="12" fill="white" stroke="{NEW}" stroke-width="2"/>')
text(XB + 12, 660, "DC breakers, BMS", 10.5, NEW)
battery(XB, 728, "LFP battery 2,622 kWh\n2 containers, heated\n10-100% SOC, 0.5C\nIEC 62619, NFPA 855", NEW)

# Diesel branch
XD = 650
line(XD, YG, XD, 640, OLD)
breaker(XD, 540, "ACB (32)", OLD, side="left")
box(XD - 70, 560, 140, 34, OLD, None, ["genset sync panel"], fill="#f5f5f3")
line(XD - 40, 594, XD - 40, 640, OLD)
line(XD + 40, 594, XD + 40, 640, OLD)
generator(XD - 40, 668, "G1", OLD)
generator(XD + 40, 668, "Gn", OLD)
text(XD, 735, "existing diesel sets\ntotal >= 520 kW (assumed)\nbackup, sunk cost", 10.5, OLD, "middle")

# aux
line(738, YG, 738, 560, NEW)
breaker(738, 535, "", NEW)
load(738, 562, "aux:\nHVAC,\nheating", NEW)

# -------------------------------------------------------------------- F2: club core (hotel etc.)
line(XF2, YMV, XF2, 470, OLD)
breaker(XF2, 380, "F2", OLD)
transformer(XF2, 430, "TX-A  20/0.4 kV\n400 kVA (existing,\nrating assumed)", OLD)
YA = 530
line(XF2, 445, XF2, YA, OLD)
breaker(XF2, 478, "", OLD)
bus(770, 1035, YA, "Club core MSB, 400 V", OLD)
# essential section
line(800, YA, 800, 560, OLD)
breaker(800, 548, "", OLD)
line(800, 556, 800, 575, OLD)
bus(785, 900, 585, "", OLD)
text(780, 612, "", 10)
for k, (lab) in enumerate(["water\npumping", "waste-\nwater", "security,\nIT"]):
    xx = 800 + k * 45
    line(xx, 585, xx, 612, OLD)
    load(xx, 612, lab, INK, crit=True)
text(785, 690, "Essential bus (critical)\n+ 30% of hotel, restaurant,\noffice and road lighting", 10.5, INK)
# non-essential section with shedding breaker
line(985, YA, 985, 585, OLD)
breaker(985, 552, "", CTRL)
text(995, 572, "shed", 10.5, CTRL, italic=True)
bus(930, 1045, 585, "", OLD)
for k, lab in enumerate(["hotel,\nrest.", "pool,\nsports", "EV\ncharger"]):
    xx = 945 + k * 45
    line(xx, 585, xx, 612, OLD)
    load(xx, 612, lab)

# ------------------------------------------------------------------------ F3: lift stations
line(XF3, YMV, XF3, 470, OLD)
breaker(XF3, 380, "F3", CTRL, side="left")
text(XF3 + 34, 374, "shed", 10.5, CTRL, italic=True)
transformer(XF3, 430, "TX-L  20/0.4 kV\n400 kVA (existing,\nassumed)", OLD)
line(XF3, 445, XF3, 530, OLD)
bus(1070, 1290, 530, "Lift stations, 400 V", OLD)
for k, lab in enumerate(["T1 chair\n150 kW", "T2\n50 kW", "T3+T4\n36 kW"]):
    xx = 1090 + k * 60
    line(xx, 530, xx, 600, OLD)
    breaker(xx, 556, "", OLD)
    load(xx, 600, lab)
line(1270, 530, 1270, 600, OLD)
breaker(1270, 556, "", OLD)
load(1270, 600, "T1 recov.\n30 kW", INK, crit=True)

# ---------------------------------------------------------------------- F4: chalets, lighting
line(XF4, YMV, XF4, 470, OLD)
breaker(XF4, 380, "F4  MV ring", CTRL, side="left")
text(XF4 + 34, 374, "shed", 10.5, CTRL, italic=True)
for k, (xx, lab) in enumerate([(1350, "TX-C1"), (1450, "TX-C2"), (1550, "TX-R")]):
    line(XF4, 455, xx, 455, OLD) if k else None
line(1350, 455, 1550, 455, OLD)
line(XF4, 445, XF4, 455, OLD)
for xx, lab, ld in [(1350, "TX-C1\n400 kVA", "chalets\n(zone 1)"), (1450, "TX-C2\n400 kVA", "chalets\n(zone 2)"),
                    (1550, "TX-R\n100 kVA", "road\nlighting")]:
    line(xx, 455, xx, 482, OLD)
    transformer(xx, 500, "", OLD)
    text(xx + 20, 478, lab, 10.5, OLD)
    line(xx, 515, xx, 600, OLD)
    load(xx, 600, ld, INK, crit=(ld == "road\nlighting"))
text(1290, 668, "Chalet and lighting substations on the club MV ring\n(existing; number and ratings assumed). Road lighting: 30% essential, dimmed.", 10.5, OLD)

# ----------------------------------------------------------------- microgrid controller
box(1180, 735, 590, 130, CTRL, "Micro-grid controller (MGC), IEEE 2030.7 / 2030.8",
    ["- dispatch: PV first, battery, EDL when available, diesel last",
     "- opens 52-PCC on loss of EDL; PCS forms the island (black start)",
     "- starts the diesel sets at low SOC; keeps sets >= 30% loaded",
     "- sheds F3, F4 and the non-essential board in priority order",
     "- re-synchronises (25) and closes 52-PCC when EDL returns",
     "- keeps the T1 recovery reserve in the battery while lifts run"])
for (x, y) in [(XPV - 44, 650), (XB - 44, 600), (XD - 84, 577), (1007, 548), (XF3 + 22, 370), (XF4 + 22, 370)]:
    tag(x, y)

# ------------------------------------------------------------------------------ legend & notes
box(30, 915, 520, 290, MUTED, "Legend",
    [], fill="white")
ly = 960
items = [("new equipment (this project)", NEW), ("existing / assumed existing", OLD)]
for k, (lab, c) in enumerate(items):
    yy = ly + k * 24
    line(50, yy, 100, yy, c, 3 if c != CTRL else 1.5, None if c != CTRL else "6,4")
    text(112, yy + 4, lab, 11.5)
yy = ly + 58
add(f'<rect x="67" y="{yy - 8}" width="16" height="16" fill="white" stroke="{INK}" stroke-width="2"/>')
text(112, yy + 4, "circuit breaker (ACB / MCCB / MV CB)", 11.5)
yy += 26
line(70, yy - 10, 79, yy + 8, INK)
text(112, yy + 4, "load-break switch / disconnector", 11.5)
yy += 26
add(f'<polygon points="67,{yy - 7} 83,{yy - 7} 75,{yy + 7}" fill="#111" stroke="#111"/>')
text(112, yy + 4, "essential (critical) load, never shed", 11.5)
yy += 24
add(f'<polygon points="67,{yy - 7} 83,{yy - 7} 75,{yy + 7}" fill="white" stroke="#111" stroke-width="2"/>')
text(112, yy + 4, "non-critical load, sheddable within the LPSP limit", 11.5)
yy += 24
text(112, yy + 4, "shed = breaker tripped by the MGC for load shedding", 11.5, CTRL)
yy += 26
tag(75, yy)
text(112, yy + 4, "device controlled by the MGC (fibre / Modbus-TCP)", 11.5)

box(570, 915, 590, 290, MUTED, "Design notes",
    ["1. Sizes from the LP base case: PV 983 kWp, BESS 2,622 kWh / 790 kW,",
     "   peak load 519 kW, EDL import limited to the peak (519 kW).",
     "2. Islanding at 20 kV, so the whole club network (lifts, chalets) can be",
     "   supplied in island mode; the battery PCS is the grid-forming source.",
     "3. No export to EDL in the base case (relay 32). Net-metering case:",
     "   disable 32, set export limit in the MGC (Law 318/2023).",
     "4. Transformer TX-G carries the net output of the generation bus",
     "   (max. load + battery charging); 1,000 kVA with margin.",
     "5. Existing transformers and genset ratings are not published; values",
     "   shown are assumptions to be checked on site.",
     "6. PV and BESS earthing TN-S on the 400 V side; PV per IEC 60364-7-712;",
     "   BESS spacing, ventilation and fire suppression per NFPA 855."])

box(1180, 915, 590, 290, MUTED, "Operating modes",
    ["A  EDL on: 52-PCC closed; PV serves load and charges the battery;",
     "   EDL covers the rest; diesel off.",
     "B  EDL off (about 16 h/day): 52-PCC open; PCS forms the island;",
     "   PV + battery serve the load; diesel sets start only when the",
     "   battery reaches its minimum reserve.",
     "C  Long outage / winter peak: diesel sets run at >= 30% load;",
     "   MGC sheds F4, F3 and the non-essential board in that order;",
     "   essential bus and T1 recovery reserve are always kept.",
     "D  EDL returns: sync-check (25), close 52-PCC, return to mode A.",
     "",
     "Standards: IEEE 1547-2018, IEEE 2030.7/2030.8, IEC 62116,",
     "IEC 62619, NFPA 855, IEC 60364-7-712, EN 13223 (lift recovery)."])

svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" '
       f'font-family="Arial, Helvetica, sans-serif"><rect width="{W}" height="{H}" fill="white"/>'
       + "".join(E) + "</svg>")
(OUT / "sld.svg").write_text(svg)
print("wrote", OUT / "sld.svg")
