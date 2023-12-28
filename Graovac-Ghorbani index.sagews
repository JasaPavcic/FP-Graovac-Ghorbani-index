︠173b89ff-c7e7-48a8-b6ae-40a1770d3632s︠
import sage.all
import math
from sage.graphs.trees import TreeIterator

def ustvariGraf(n):
    G = Graph()
    G.add_vertices(range(n))
    return G

def dodajVozlisce(G, oznaka):
    G.add_vertex(oznaka)

def odstraniVozlisce(G, oznaka):
    G.delete_vertex(oznaka)

def dodajPovezavo(G, zacetek, konec):
    G.add_edge(zacetek, konec)

def odstraniPovezavo(G, zacetek, konec):
    G.remove_edge(zacetek, konec)

def dodajPovezave(G, seznam_parov):
    G.add_edges(seznam_parov)

def razdaljeOglisc(G):
    G.distance_all_pairs()

def GGI(G):
    n = G.order() #stevilo ogljisc v grafu
    vsota = 0
    #iteracija po robovih
    for (u, v,_) in G.edges():
        nu_v = sum(1 for x in G.vertices() if G.shortest_path_length(u, x) < G.shortest_path_length(v, x))
        nv_u = sum(1 for x in G.vertices() if G.shortest_path_length(v, x) < G.shortest_path_length(u, x))
        if nu_v + nv_u - 2 > 0:
            vsota += sqrt((nu_v + nv_u - 2) / (nu_v * nv_u))

    return vsota


A = ustvariGraf(4)
dodajPovezave(A,[(3,4),(4,0),(1,2),(0,1),(2,3)])
A.plot()
vsota = GGI(A)
#n je zato ker drugace ne vrne numericne vrednosti
print(n(vsota))


#narišem vsa drevesa s fiksnim številom vozlišč od 1 do 5 in na njih izračunam GGI
l = 6
for n in range(1, l):
    tree_iterator = graphs.trees(n)
    for T in tree_iterator:
        T.plot()
        vrednost = float(GGI(T))
        print(vrednost)

#narišem vse povezane dvodelne grafe na od 1 do 5 vozliščih in na njih izračunam GGI
k = 5 #stevilo vozlisc
sez_dvodelnih = list( graphs(k, lambda G: G.is_bipartite(), augment='vertices') )
for g in sez_dvodelnih:
    if g.is_connected() and g.order() > 0: #narisem samo tiste z vsaj 1 vozliscem in poskrbim, da so grafi povezani
        plot(g)
        vrednost = float(GGI(g))
        print(vrednost)
        
#narisem vse grafe brez trikotnikov na 1 do 5 vozliscih in na njih izracunam GGI
m = 5
sez_grafov_1 = list(graphs(m, augment='vertices'))
sez_brez_t = []
for g in sez_grafov_1:
    if vsebuje_trikotnik(g) == False and g.is_connected() == True:
        sez_brez_t.append(g)
for g in sez_brez_t:
    if g.order() > 0: #narisem samo tiste z vsaj 1 vozliscem
        plot(g)
        vrednost = float(GGI(g))
        print(vrednost)
        
#narisem vse splosne povezane grafe na 1 do 5 vozliscih in na njih izracunam GGI. Ustvarim tudi seznam, v katerem bodo 'tuples', ki bodo vsebovali graf in njegov GG indeks. Nato bom ta seznam uredila po narascajocem indeksu, da vidim, kateri grafi imajo velik in kateri majhen indeks.
n = 5 #stevilo vozlisc
seznam = []
sez_grafov = list(graphs(n, augment='vertices')) #seznam vseh moznih grafov z od 0 do n vozlisci
sez_povezanih = []
for g in sez_grafov:
    if g.is_connected() == True: #upostevam samo povezane grafe      
        sez_povezanih.append(g)
for g in sez_povezanih:
    if g.order() > 0: #narisem samo tiste z vsaj 1 vozliscem
        plot(g)
        vrednost = float(GGI(g))
        print(vrednost)
        seznam.append((g, vrednost))        
        
seznam.sort(key=lambda x: x[1]) #seznam uredim narascajoce po indeksu
for i in range(1,4): #narisem si tri grafe z najmanjsim indeksom
    g = seznam[i][0]
    plot(g)
    print(seznam[i][1])
    
for tuple in seznam[-3:]: #narisem si tri grafe z najvecjim indeksom
    g = tuple[0]
    plot(g)
    print(tuple[1])


︡d471d081-b59f-4595-ab16-f8787d263243︡{"file":{"filename":"/tmp/tmpb7ko6kzb/tmp_zy5rov5k.svg","show":true,"text":null,"uuid":"ee65591e-a60f-4f51-a801-fea37a6b5113"},"once":false}︡{"stdout":"3.53553390593274\n"}︡{"done":true}
︠7d24e49f-5dee-4851-a879-575bddd12fbb︠









