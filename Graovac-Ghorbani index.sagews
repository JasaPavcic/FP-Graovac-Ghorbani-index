︠2a6b6f1f-afea-4b44-b347-744c705d074b︠
import sage.all
import numpy
import math
from sage.graphs.trees import TreeIterator
import random
from sage.plot.plot import list_plot
from sage.graphs.random import GaussianRandomGraph
import itertools
import pandas as pd

#ustvari graf na n vozliščih
def ustvariGraf(n):
    G = Graph()
    G.add_vertices(range(n))
    return G

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
                if G.is_tree(): #ce imamo drevo, bo vsaka odstranjena povezana povzrocila nepovezan graf, zato v tem primeru povezavo dodamo
                    dodaj_povezavo()
                else: #sicer povezavo odstranimo
                    odstrani_drevesno_povezavo()
            else: dodaj_povezavo() if len(S.edges()) < len(S.vertices()) * (len(S.vertices()) - 1) else odstrani_drevesno_povezavo()
            return S

        elif tip_grafa == 'dr':
            odstrani_povezavo()
            locena_grafa = S.connected_components() #izmed teh dveh grafov izberem dve nakljucni vozljisci in ju povezem
            u = random.choice(locena_grafa[0])
            v = random.choice(locena_grafa[1])
            S.add_edge(u, v)
            return S

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
            return S

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
def temperatura(T, a, l):
    stopinje = T * math.exp(-a * l)
    return stopinje


# funkcija simuliranega ohlajanja sprejme zacetni graf (G_0), najvecje stevilo korakov (k_max), zacetno temperaturo (T_0), parameter ohlajanja (a), tip grafa (tip_grafa) in podatek o tem, a iscem minimum ali maksimum (kaj_iscem): ce iscem minimum vstavim 'min', ce maksimum pa 'max'

def simulirano_ohlajanje(G_0, k_max, T_0, a, tip_grafa, kaj_iscem):
    iscem = {'min', 'max'}
    if kaj_iscem not in iscem:
        raise ValueError("simulirano_ohlajanje: kaj_iscem mora biti v %r." % iscem)
    else:
        sez_tuplov_k_temp = [] #naredim nekaj pomoznih seznamov, da si bom lahko plotala delovanje algoritma
        sez_tuplov_k_ggi = []
        sez_ggi = []
        sez_verjetnosti = []
        G = G_0
        T = T_0
        for k in range(k_max):
            T = temperatura(T, a, k)  # to funkcijo temperatura moram se razmisliti, to je samo en mozen primer
            G_1 = neighbour(G, tip_grafa)
            p =  random.random()
            verjetnost_prehoda = P(G, G_1, T, kaj_iscem)
            if verjetnost_prehoda >= p:
                G = G_1

            sez_tuplov_k_temp.append((k, T)) #na pomozne sezname dodam vrednosti
            sez_tuplov_k_ggi.append((k, GGI(G)))
            sez_ggi.append(GGI(G))
            sez_verjetnosti.append((k, verjetnost_prehoda))

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




###

#F = graphs.RandomTree(15)

###

#F = graphs.RandomBipartite(16, 10, 0.5)

###

#F = GaussianRandomGraph(10, 0.5 , 0.1)

###



#3. del - eksperimentiranje

###mozni parametri
k_max_vrednosti = [25, 50, 100]
T_0_vrednosti = [500, 1000, 2000,5000,10000]
a_vrednosti = [0.95, 0.96, 0.97, 0.99]
tip_grafa_vrednosti = ['op', 'bt', 'dr', 'dv']
kaj_iscem_vrednosti = ['min', 'max']

####ustvari kombinacije
mozne_kombinacije = list(itertools.product(k_max_vrednosti, T_0_vrednosti, a_vrednosti, tip_grafa_vrednosti, kaj_iscem_vrednosti))

####lepsi format
mozne_kombinacije = [{'k_max': k_max, 'T_0': T_0, 'a': a, 'tip_grafa': tip_grafa, 'kaj_iscem': kaj_iscem} for
                  (k_max, T_0, a, tip_grafa, kaj_iscem) in mozne_kombinacije]


####tabela rezultatov
rezultati_df = pd.DataFrame(columns=['k_max', 'T_0', 'a', 'tip_grafa', 'kaj_iscem', 'Koncni GGI', 'st_vozlisc'])



####simulacija (treba dodat, da ne bo delal samo na drevesih)
for n in range(5,6):
    print('število vozlišč:',n)
    F = graphs.RandomTree(n)
    for mozna_kombinacija in mozne_kombinacije:
        print(mozna_kombinacija)
        G = simulirano_ohlajanje(F, mozna_kombinacija['k_max'], mozna_kombinacija['T_0'], mozna_kombinacija['a'], mozna_kombinacija['tip_grafa'], mozna_kombinacija['kaj_iscem'])
        G.plot()
        vGGI = float(GGI(G))
        print('kočni GGI:',vGGI)
        nova_vrstica = [mozna_kombinacija['k_max'],
                        mozna_kombinacija['T_0'],
                        mozna_kombinacija['a'],
                        mozna_kombinacija['tip_grafa'],
                        mozna_kombinacija['kaj_iscem'],
                        vGGI,
                        n]
        print('nova vrstica')
        rezultati_df.loc[len(rezultati_df)] = nova_vrstica
        print(rezultati_df)

print(rezultati_df)

###obdelava podatkov


grupirani = df.groupby(['st_vozlisc', 'tip_grafa', 'kaj_iscem'])

#maksimum za določene kombinacije

rezultati = grouped_df.apply(lambda x: x.loc[x['Koncni GGI'].idxmax()])









