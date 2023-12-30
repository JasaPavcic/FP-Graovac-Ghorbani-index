︠173b89ff-c7e7-48a8-b6ae-40a1770d3632s︠
︠5cb6a965-0426-426a-b743-fff68a29072b︠
import sage.all
import math
from sage.graphs.trees import TreeIterator
import random

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

#definiram funkcijo, ki mi pove, ali je v grafu trikotnik
def vsebuje_trikotnik(G):
    for povezava in G.edges():
      for vozl in G.vertices():       
         if G.has_edge(vozl, povezava[0]) and G.has_edge(vozl, povezava[1]):
              return True
    return False

#1. del - tocno racunanje

#definiram funkcijo, ki sprejme stevilo vozlisc (n) in tip grafa (obicajen povezan (op), brez trikotnikov (bt), drevo (dr), dvodelen (dv)) in vrne seznam 'tuplov', kjer je prvi element vsakega tupla graf ustreznega tipa na n vozliscih, drugi pa pripadajoc GGI. Seznam je urejen narascajoce po indeksu.
#opomba: graf je tipa 'op', ce je povezan in ne ustreza nobenemu drugemu tipu
def GGI_na_fiksnem_st_vozl(n, tip_grafa):
    tipi = {'op', 'bt', 'dr', 'dv'}
    if tip_grafa not in tipi:
        raise ValueError("GGI_na_fiksnem_st_vozl: tip_grafa mora biti v %r." % tipi)
    else:
        vsi_grafi = list(graphs(n))
        povezani_grafi = [graf for graf in vsi_grafi if graf.is_connected()]
        seznam = [] #to bo seznam 'tuplov'
        if tip_grafa == 'op':
            for g in povezani_grafi:
                if g.order() > 0: #narisem samo tiste z vsaj 1 vozliscem
                    vrednost = float(GGI(g))
                    seznam.append((g, vrednost))
        elif tip_grafa == 'bt':
            for g in povezani_grafi:
                if vsebuje_trikotnik(g) == False and g.order() > 0: #upostevam samo tiste z vsaj 1 vozliscem
                    vrednost = float(GGI(g))
                    seznam.append((g, vrednost))
        elif tip_grafa == 'dr':
            tree_iterator = graphs.trees(n)
            for g in tree_iterator:
                vrednost = float(GGI(g))    
                seznam.append((g, vrednost))
        elif tip_grafa == 'dv':
            for g in povezani_grafi:
                if g.is_bipartite() and g.order() > 0:
                    vrednost = float(GGI(g))
                    seznam.append((g, vrednost))
        seznam.sort(key=lambda x: x[1]) #uredim seznam tuplov
        for tuple in seznam:
            graf = tuple[0]
            indeks = tuple[1]
            show(plot(graf))
            print(indeks)
        return seznam    
    
#GGI_na_fiksnem_st_vozl(7, 'op') pri n = 7 ze dobim error 'too many output messages' - od tu naprej bo treba uporabiti metahevristiko

#2. del - simulirano ohlajanje

#definiram parametre

#a) sosednja stanja

#funkcija neighbour doda oziroma odstrani nakljucno povezavo. Funkcija poskrbi, da je nov graf se vedno povezan, istega tipa in da ne dodam povezave, kjer ta ze obstaja.
def neighbour(G, tip_grafa):
    tipi = {'op', 'bt', 'dr', 'dv'}
    S = G.copy()
    if tip_grafa not in tipi:
        raise ValueError("GGI_na_fiksnem_st_vozl: tip_grafa mora biti v %r." % tipi)
    else:
        if tip_grafa == 'op':
            if random.random() < 0.5: #v tem primeru naceloma odstranjujemo povezave, razen ce imamo drevo
                if G.is_tree() == True: #ce imamo drevo, bo vsaka odstranjena povezana povzrocila nepovezan graf, zato v tem primeru povezavo dodamo 
                    nepovezani_pari_vozl = [(u, v) for u in S.vertices() for v in S.vertices() if u != v and not S.has_edge(u, v)]    
                    uv = random.choice(nepovezani_pari_vozl)
                    S.add_edge(uv)
                else: #sicer povezavo odstranimo
                    random_edge = S.random_edge()
                    S.delete_edge(random_edge)
                    while S.is_connected == False:
                        if random_edge not in S.edges():
                            S.add_edge(random_edge)                       
                        random_edge = S.random_edge()
                        S.delete(random_edge)                           
                return S               
            else: #v tem primeru naceloma dodajamo povezave, razen ce imamo poln graf
                nepovezani_pari_vozl = [(u, v) for u in S.vertices() for v in S.vertices() if u != v and not S.has_edge(u, v)]
                if len(nepovezani_pari_vozl) == 0: #v primeru polnega grafa odstranimo povezavo
                    random_edge = S.random_edge()
                    S.delete_edge(random_edge)
                else: #sicer jo dodamo
                    uv = random.choice(nepovezani_pari_vozl)
                    S.add_edge(uv)    
                return S
            
            
        elif tip_grafa == 'dr': 
            random_edge = S.random_edge()
            S.delete_edge(random_edge) #odstranim nakljucno povezavo, dobim dva locena grafa
            locena_grafa = S.connected_components() #izmed teh dveh grafov izberem dve nakljucni vozljisci in ju povezem
            u = random.choice(locena_grafa[0])
            v = random.choice(locena_grafa[1])
            S.add_edge(u, v)
            return S
        
        
        elif tip_grafa == 'dv':
            S = BipartiteGraph(S)
            sez_seznamov_vozl = []
            sez_mnozic_vozl = S.bipartition()
            for mnoz in sez_mnozic_vozl: #ustvarim seznam dveh seznamov, da potem do njiju lahko dostopam
                sez_seznamov_vozl.append(sorted(mnoz))
                
            g_0 = S
            #naredim g_0 in g_1 kot dva mozna grafa, na katerih iscem sosede. razlikujeta se v mnozici 
            
#           if len(sez_seznamov_vozl[0]) == 1:

            if random.random() < 0.5: #dodam povezavo, ce graf se ni poln (v dvodelnem smislu)
                if len(S.edges()) == len(sez_seznamov_vozl[0]) * len(sez_seznamov_vozl[1]): #test za polnost dvodelnega grafa
                    random_edge = S.random_edge() #v tem primeru odstranim povezavo
                    S.delete_edge(random_edge)
                else: #sicer jo dodam in pazim, da ne dodam povezave, ki ze obstaja
                    nepovezani_pari_vozl = [(u, v) for u in sez_seznamov_vozl[0] for v in sez_seznamov_vozl[1] if not S.has_edge(u, v)]    
                    uv = random.choice(nepovezani_pari_vozl)
                    S.add_edge(uv)
            
            else: #odstranim povezavo in poskrbim, da je graf se vedno povezan
                if S.is_tree() == True: #v tem primeru ne morem nobene povezave odstraniti, zato jo dodam
                    u = random.choice(sez_seznamov_vozl[0])
                    v = random.choice(sez_seznamov_vozl[1])
                    S.add_edge(u, v)
                else: #sicer povezavo odstranim
                    random_edge = S.random_edge()
                    S.delete_edge(random_edge)
                    while S.is_connected() == False:
                        if random_edge not in S.edges():
                            S.add_edge(random_edge)                       
                        random_edge = S.random_edge()
                        S.delete_edge(random_edge) 
            return S
        
        
        elif tip_grafa == 'bt':
            if random.random() < 0.5: #v tem primeru naceloma odstranjujemo povezave, razen ce imamo drevo
                if S.is_tree() == True: 
                    nepovezani_pari_vozl = [(u, v) for u in S.vertices() for v in S.vertices() if u != v and not S.has_edge(u, v)]    
                    uv = random.choice(nepovezani_pari_vozl)
                    S.add_edge(uv)
                    while vsebuje_trikotnik(S) == True or S.is_connected() == False:
                        if random.random() < 0.5:
                            nepovezani_pari_vozl = [(u, v) for u in S.vertices() for v in S.vertices() if u != v and not S.has_edge(u, v)]    
                            uv = random.choice(nepovezani_pari_vozl)
                            S.add_edge(uv)
                        else:
                            random_edge = S.random_edge()       
                            S.delete_edge(random_edge)
                else:
                    random_edge = S.random_edge()
                    while S.is_cut_edge(random_edge) == True:                   
                        random_edge = S.random_edge()
                    S.delete_edge(random_edge)
                    
            else: #sicer povezavo dodamo
                nepovezani_pari_vozl = [(u, v) for u in S.vertices() for v in S.vertices() if u != v and not S.has_edge(u, v)]    
                uv = random.choice(nepovezani_pari_vozl)
                S.add_edge(uv)
                while vsebuje_trikotnik(S) == True or S.is_connected() == False:                    
                    if random.random() < 0.5:
                        nepovezani_pari_vozl = [(u, v) for u in S.vertices() for v in S.vertices() if u != v and not S.has_edge(u, v)]    
                        uv = random.choice(nepovezani_pari_vozl)
                        S.add_edge(uv)
                    else:
                        random_edge = S.random_edge()       
                        S.delete_edge(random_edge)                

            return S            
        
                
#b) verjetnost sprejema                   
def P(G_0, G_1, T):
    e_0 = GGI(G_0)
    e_1 = GGI(G_1)
    if e_1 < e_0:
        return 1
    else:
        rezultat = exp(-(e_1 - e_0) / T)
        return rezultat
    
#c) temperaturna funkcija
def T(k):
    rezultat = (a * T_0) / log(1 + k)
    return rezultat

# funkcija simuliranega ohlajanja
def simulirano_ohlajanje(G, k_max, a, T_0, tip_grafa):
    G = G_0
    for k in range(0, k_max):
        G_1 = neigbour(G, tip_grafa)
        if P(G_0, G_1, T) >= random.random():
            G_0 = G_1
    return G  

G = ustvariGraf(5)
dodajPovezave(G, [(0, 1), (1, 2), (3, 1), (4,2), (0, 4), (4, 5)])
G.plot()
s = neighbour(G, 'bt')

s.plot()


︡d471d081-b59f-4595-ab16-f8787d263243︡{"file":{"filename":"/tmp/tmpb7ko6kzb/tmp_zy5rov5k.svg","show":true,"text":null,"uuid":"ee65591e-a60f-4f51-a801-fea37a6b5113"},"once":false}︡{"stdout":"3.53553390593274\n"}︡{"done":true}
︠7d24e49f-5dee-4851-a879-575bddd12fbb︠









