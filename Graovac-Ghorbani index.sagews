︠788770f2-a86a-49e2-9b75-2cf8f767f010︠
import sage.all
import numpy
import math
from sage.graphs.trees import TreeIterator
import random
from sage.plot.plot import list_plot
import itertools
import pandas as pd
import networkx as nx
import time



#funkcija za izračun Graovac-Ghorbani indexa
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

#definiram funkcijo, ki sprejme stevilo vozlisc (n) in tip grafa (obicajen povezan (op), brez trikotnikov (bt), drevo (dr), dvodelen (dv)) in vrne seznam 'tuplov', kjer je prvi element vsakega tupla graf ustreznega tipa na n vozliscih, drugi pa pripadajoc GGI. Seznam je urejen narascajoce po indeksu. Parameter show_plot pove, ali rezultate graficno predstavimo ali ne.
def GGI_na_fiksnem_st_vozl(n, tip_grafa, show_plot=True):
    tipi = {'op', 'bt', 'dr', 'dv'}
    if tip_grafa not in tipi:
        raise ValueError("GGI_na_fiksnem_st_vozl: tip_grafa mora biti v %r." % tipi)
    else:
        vsi_grafi = list(graphs(n))
        povezani_grafi = [graf for graf in vsi_grafi if graf.is_connected()]
        seznam = [] #to bo seznam 'tuplov'
        if tip_grafa == 'op':
            for g in povezani_grafi:
                vrednost = float(GGI(g))
                seznam.append((g, vrednost))
        elif tip_grafa == 'bt':
            for g in povezani_grafi:
                if vsebuje_trikotnik(g) == False:
                    vrednost = float(GGI(g))
                    seznam.append((g, vrednost))
        elif tip_grafa == 'dr':
            tree_iterator = graphs.trees(n)
            for g in tree_iterator:
                vrednost = float(GGI(g))
                seznam.append((g, vrednost))
        elif tip_grafa == 'dv':
            for g in povezani_grafi:
                if g.is_bipartite():
                    vrednost = float(GGI(g))
                    seznam.append((g, vrednost))
        seznam.sort(key=lambda x: x[1]) #uredim seznam tuplov
        if show_plot == True:
            for tuple in seznam:
                graf = tuple[0]
                indeks = tuple[1]
                show(graf.plot())
                print(indeks)
        return seznam

#2. del - simulirano ohlajanje

#definiram parametre

#a) sosednja stanja


#funkcija neighbour doda oziroma odstrani nakljucno povezavo. Funkcija poskrbi, da je nov graf se vedno povezan, istega tipa in da ne dodam povezave, kjer ta ze obstaja.
def neighbour(G, tip_grafa):

    def dodaj_povezavo():
        nonlocal S
        nepovezani_pari_vozl = [(u, v) for u in S.vertices() for v in S.vertices() if u != v and not S.has_edge(u, v)]
        if nepovezani_pari_vozl:
            uv = random.choice(nepovezani_pari_vozl)
            S.add_edge(uv)

    def odstrani_drevesno_povezavo():
        nonlocal S
        random_edge = S.random_edge()
        while S.is_cut_edge(random_edge):
            random_edge = S.random_edge()
        S.delete_edge(random_edge)

    def odstrani_povezavo():
        nonlocal S
        if len(S.edges()) > 0:
            random_edge = S.random_edge()
            S.delete_edge(random_edge)

    def povezi():
        while vsebuje_trikotnik(S) == True or S.is_connected() == False:
            if random.random() < 0.5:
                dodaj_povezavo()
            else:
                odstrani_povezavo()

    tipi = {'op', 'bt', 'dr', 'dv'}
    S = G.copy()
    if tip_grafa not in tipi:
        raise ValueError("GGI_na_fiksnem_st_vozl: tip_grafa mora biti v %r." % tipi)
    else:
        if tip_grafa == 'op':
            if random.random() < 0.5: #v tem primeru naceloma odstranjujemo povezave, razen ce imamo drevo
                if G.is_tree(): #ce imamo drevo, bo vsaka odstranjena povezana povzrocila nepovezan graf; dodamo povezavo
                    dodaj_povezavo()
                else: #sicer povezavo odstranimo
                    odstrani_drevesno_povezavo()
            else: #v tem primeru naceloma dodajamo povezave, razen ce imamo poln graf
                if len(S.edges()) == n*(n-1)/2:  #v tem primeru je graf poln
                    odstrani_drevesno_povezavo()
                else:
                    dodaj_povezavo()

        elif tip_grafa == 'dr':
            odstrani_povezavo()
            locena_grafa = S.connected_components() #izmed teh dveh grafov izberem dve nakljucni vozljisci in ju povezem
            u = random.choice(locena_grafa[0])
            v = random.choice(locena_grafa[1])
            S.add_edge(u, v)


        elif tip_grafa == 'dv':
            S = BipartiteGraph(S)

            if len(S.left) == 1: #v teh primerih moramo spremeniti mnozici vozlisc
                vozl = random.choice(list(S.right))
                S.delete_vertex(vozl)
                S.left.add(vozl)
                v = random.choice(list(S.right))
                S.add_edge(vozl, v)

            elif len(S.right) == 1:
                vozl = random.choice(list(S.left))
                S.delete_vertex(vozl)
                S.right.add(vozl)
                u = random.choice(list(S.left))
                S.add_edge(vozl, u)

            else: #sicer ali dodamo/odstranimo povezavo, ali spremenimo mnozici vozlisc
                r = random.random()
                if r < 0.25: #iz leve prestavim na desno eno vozlisce
                    vozl = random.choice(list(S.left))
                    S.delete_vertex(vozl)
                    S.right.add(vozl)
                    S.add_vertex(vozl, right=True)
                    while not S.is_connected():
                        u = random.choice(list(S.left))
                        S.add_edge(vozl, u)
                        for vozl in S.right:
                            if S.degree(vozl) == 0:
                                levo_vozl = random.choice(list(S.left))
                                S.add_edge(levo_vozl, vozl)
                elif 0.25 <= r < 0.5: #iz desne prestavim na levo eno vozlisce
                    vozl = random.choice(list(S.right))
                    S.delete_vertex(vozl)
                    S.left.add(vozl)
                    S.add_vertex(vozl, left = True)
                    while not S.is_connected():
                        v = random.choice(list(S.right))
                        S.add_edge(vozl, v)
                        for vozl in S.left:
                            if S.degree(vozl) == 0:
                                desno_vozl = random.choice(list(S.right))
                                S.add_edge(desno_vozl, vozl)
                elif 0.5 <= r < 0.75: #dodam povezavo, ce graf se ni poln (v dvodelnem smislu)
                    if len(S.edges()) == len(S.left) * len(S.right): #test za polnost dvodelnega grafa
                        odstrani_povezavo()
                    else: #sicer jo dodam in pazim, da ne dodam povezave, ki ze obstaja
                        nepovezani_pari_vozl = [(u, v) for u in S.left for v in S.right if not S.has_edge(u, v)]
                        uv = random.choice(nepovezani_pari_vozl)
                        S.add_edge(uv)

                else: #odstranim povezavo in poskrbim, da je graf se vedno povezan
                    if S.is_tree(): #v tem primeru ne morem nobene povezave odstraniti, zato jo dodam
                        u = random.choice(list(S.left))
                        v = random.choice(list(S.right))
                        S.add_edge(u, v)
                    else: #sicer povezavo odstranim
                        odstrani_drevesno_povezavo()


        elif tip_grafa == 'bt':
            #dodamo random povezavo in potem 'popravljamo', dokler graf ni ustrezne oblike
            if random.random() < 0.5:
                dodaj_povezavo()
                povezi()
            else:
                #odstranimo random povezavo in potem 'popravljamo', dokler graf ni ustrezne oblike
                random_edge = S.random_edge()
                S.delete_edge(random_edge)
                povezi()
        return S


#b) verjetnost prehoda; razlikuje se glede na to, ali iscemo min ali max
def P(G, G_1, T, kaj_iscem):
    iscem = {'min', 'max'}
    if kaj_iscem not in iscem:
        raise ValueError("simulirano_ohlajanje: kaj_iscem mora biti v %r." % iscem)
    else:
        if kaj_iscem == 'min':
            e = GGI(G)
            e_1 = GGI(G_1)
        else:
            e = -GGI(G)
            e_1 = -GGI(G_1)
        if e_1 < e:
            return 1
        else:
            verjetnost = math.exp(-(e_1 - e) / T)
            return verjetnost


#c) temperaturna funkcija
def temperatura(T_0, a, k):
    stopinje = T_0 * a^k
    return stopinje


# funkcija simuliranega ohlajanja sprejme zacetni graf (G_0), najvecje stevilo korakov (k_max), zacetno temperaturo (T_0), parameter ohlajanja (a), tip grafa (tip_grafa) in podatek o tem, a iscem minimum ali maksimum (kaj_iscem): ce iscem minimum vstavim 'min', ce maksimum pa 'max'. Dodan je se parameter show_plot, ki pove, ali narisemo slike ali ne.

def simulirano_ohlajanje(G_0, k_max, T_0, a, tip_grafa, kaj_iscem, show_plot=True):
    iscem = {'min', 'max'}
    if kaj_iscem not in iscem:
        raise ValueError("simulirano_ohlajanje: kaj_iscem mora biti v %r." % iscem)
    else:
        sez_tuplov_k_temp = [] #naredim nekaj pomoznih seznamov, da si bom lahko plotala delovanje algoritma
        sez_tuplov_k_ggi = []
        sez_ggi = []
        sez_verjetnosti = []
        G = G_0
        for k in range(k_max):
            T = temperatura(T_0, a, k)
            G_1 = neighbour(G, tip_grafa)
            p =  random.random()
            verjetnost_prehoda = P(G, G_1, T, kaj_iscem)
            if verjetnost_prehoda >= p:
                G = G_1

            sez_tuplov_k_temp.append((k, T)) #na pomozne sezname dodam vrednosti
            sez_tuplov_k_ggi.append((k, GGI(G)))
            sez_ggi.append(GGI(G))
            sez_verjetnosti.append((k, verjetnost_prehoda))
        if show_plot == True:
            p = list_plot(sez_tuplov_k_temp, title = 'T(k)', plotjoined = True) #narisem podatke, ki mi bodo v pomoc
            p.show()
            sez_tuplov_k_min = []
            if kaj_iscem == 'min':
                m = numpy.minimum.accumulate(sez_ggi)
            else:
                m = numpy.maximum.accumulate(sez_ggi)
            for i in range(len(m)):
                sez_tuplov_k_min.append((i, m[i]))
            l = list_plot(sez_tuplov_k_ggi, title = 'GGI(k)', plotjoined = True)
            l += list_plot(sez_tuplov_k_min, plotjoined = True, color = 'red')
            l.show()
            j = list_plot(sez_verjetnosti, title = 'verjetnost prehoda(k)', plotjoined = True)
            j.show()
        return G

#tole si loh za test zazenes, mislim da uredu dela:

#simulirano_ohlajanje(graphs.RandomBipartite(6,7, p = 0.5), 500, 500, 0.95, 'dv', 'max')
#simulirano_ohlajanje(graphs.RandomTree(10), 500, 500, 0.95, 'op', 'min')

#3. del - eksperimentiranje

###mozni parametri
k_max_vrednosti = [200] #malo sem povecala stevilo korakov
T_0_vrednosti = [1000]
a_vrednosti = [0.9]
tip_grafa_vrednosti = ['op', 'bt', 'dr', 'dv']
kaj_iscem_vrednosti = ['min', 'max']

####ustvari kombinacije
mozne_kombinacije = list(itertools.product(k_max_vrednosti, T_0_vrednosti, a_vrednosti, tip_grafa_vrednosti, kaj_iscem_vrednosti))

####lepsi format
mozne_kombinacije = [{'k_max': k_max, 'T_0': T_0, 'a': a, 'tip_grafa': tip_grafa, 'kaj_iscem': kaj_iscem} for
                  (k_max, T_0, a, tip_grafa, kaj_iscem) in mozne_kombinacije]


####tabela rezultatov
rezultati_df = pd.DataFrame(columns=['k_max', 'T_0', 'a', 'tip_grafa', 'kaj_iscem', 'Koncni GGI', 'st_vozlisc'])



def grafBrezTrikotnika(n):
    g = graphs.RandomGNP(n,0.4)
    while vsebuje_trikotnik(g):
        g = graphs.RandomGNP(n,0.4)
    return g


####eksperiment
for n in(8):
    print('število vozlišč:', n)
    
    #možne strukture grafov
    grafi2 = {
              'bt' : grafBrezTrikotnika(n)
              'dv' : graphs.RandomBipartite(n,n, p = 0.5)
              'op' : graphs.RandomGNP(n,.4)
              'dr' : graphs.RandomTree(n)
              }
    začetek = time.time()
    for key,value in grafi2.items():

        tip_grafa = key
        F = value
        for kaj_iscem in ('min','max'):

            print('iscem \b ' + kaj_iscem + '\b pri  \b'  + str(n) + '\b vozliščih na \b' + tip_grafa + '\b grafu')

            if kaj_iscem == 'max':
                ekstrem = 0
                graf = F
            else:
                ekstrem = n
                graf = F
            #iteracija skozi vse možne kombinacije parametrov
            for mozna_kombinacija in mozne_kombinacije:
                G = simulirano_ohlajanje(F, mozna_kombinacija['k_max'], mozna_kombinacija['T_0'], mozna_kombinacija['a'], tip_grafa, kaj_iscem, False) #parameter False poskrbi za to da se ti ne bodo na vsakem koraku risali grafi
                vGGI = float(GGI(G))
                print('kočni GGI:',vGGI)
                #shranjevanje optimalne vrednosti glede na vhod kaj_iscem
                if kaj_iscem == 'max' and vGGI > ekstrem:
                    ekstrem = vGGI
                    graf = G
                elif kaj_iscem == 'min' and vGGI < ekstrem:
                    ekstrem = vGGI
                    graf = G
                else:
                    ekstrem = ekstrem
                    graf = graf
                #konec i-te iteracije in zapis rezultatov v tabelo za lažji pregled
                nova_vrstica = [mozna_kombinacija['k_max'],
                                mozna_kombinacija['T_0'],
                                mozna_kombinacija['a'],
                                tip_grafa,
                                kaj_iscem,
                                vGGI,
                                n]
                rezultati_df.loc[len(rezultati_df)] = nova_vrstica

            print(rezultati_df)
            print('to je \b' + kaj_iscem + '\b za \b' + tip_grafa + '\b na: \b' + str(n) + '\b vozliščih \n ' + str(ekstrem) )
            graf.plot()
    konec = time.time()

    #izpis časa izvajanja celotne zanke
    čas_izvajanja_zanke = konec - začetek
    print('eksperiment na: \b'+ str(n) + '\b vozliščih sem izvajal: \b' + str(čas_izvajanja_zanke) + ' \b sekund' )










