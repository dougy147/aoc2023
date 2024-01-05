#!/usr/bin/env python3
# Lazy last day with visualization :)

import networkx as nx
import matplotlib.pyplot as plt

filepath = "./assets/25.txt"

MODULES = {}
with open(filepath,'r') as f:
    for line in f.readlines():
        line = line.replace("\n","")
        module,connected_to = line.split(": ")
        MODULES[module] = []
        for con in connected_to.split(" "):
            MODULES[module].append(con)
f.close()

MOD = {}
for m in MODULES:
    if m not in MOD:
        MOD[m] = MODULES[m]
    for sub in MODULES[m]:
        if sub not in MOD:
            MOD[sub] = [m]
        else:
            if m not in MOD[sub]:
                MOD[sub].append(m)
        if sub not in MOD[m]:
            MOD[m].append(sub)

## First round
#G = nx.Graph()
#for m in MOD:
#    for n in MOD[m]:
#        G.add_edge(m,n)
#nx.draw(G,with_labels=True)
#plt.savefig("modules.png")

# Cut those!
MOD['cvx'].pop(MOD['cvx'].index('dph'))
MOD['dph'].pop(MOD['dph'].index('cvx'))

MOD['pzc'].pop(MOD['pzc'].index('vps'))
MOD['vps'].pop(MOD['vps'].index('pzc'))

MOD['sgc'].pop(MOD['sgc'].index('xvk'))
MOD['xvk'].pop(MOD['xvk'].index('sgc'))

G = nx.Graph()
for m in MOD:
    for n in MOD[m]:
        G.add_edge(m,n)
subgraphs = list(nx.connected_components(G))
print(len(subgraphs[0])*len(subgraphs[1]))
