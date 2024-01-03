︠173b89ff-c7e7-48a8-b6ae-40a1770d3632s︠
︠5cb6a965-0426-426a-b743-fff68a29072b︠
︠01528129-53de-4383-b4b5-9288ffb4d076︠

︠01528129-53de-4383-b4b5-9288ffb4d076s︠
import sage.all
import numpy
import math
from sage.graphs.trees import TreeIterator
import random
from sage.plot.plot import list_plot

def ustvariGraf(n):
    G = Graph()
    G.add_vertices(range(n))
    return G

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
                    while S.is_cut_edge(random_edge) == True:
                        random_edge = S.random_edge()
                    S.delete_edge(random_edge)
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
                if random.random() < 0.25: #iz leve prestavim na desno eno vozlisce
                    vozl = random.choice(list(S.left))
                    S.delete_vertex(vozl)
                    S.right.add(vozl)
                    S.add_vertex(vozl, right=True)
                    while S.is_connected() == False:
                        u = random.choice(list(S.left))
                        S.add_edge(vozl, u)
                        for vozl in S.right:
                            if S.degree(vozl) == 0:
                                levo_vozl = random.choice(list(S.left))
                                S.add_edge(levo_vozl, vozl)
                elif 0.25 <= random.random() < 0.5: #iz desne prestavim na levo eno vozlisce
                    vozl = random.choice(list(S.right))
                    S.delete_vertex(vozl)
                    S.left.add(vozl)
                    S.add_vertex(vozl, left = True)
                    while S.is_connected() == False:
                        v = random.choice(list(S.right))
                        S.add_edge(vozl, v)
                        for vozl in S.left:
                            if S.degree(vozl) == 0:
                                desno_vozl = random.choice(list(S.right))
                                S.add_edge(desno_vozl, vozl)
                elif 0.5 <= random.random() < 0.75: #dodam povezavo, ce graf se ni poln (v dvodelnem smislu)
                    if len(S.edges()) == len(S.left) * len(S.right): #test za polnost dvodelnega grafa
                        random_edge = S.random_edge() #v tem primeru odstranim povezavo
                        S.delete_edge(random_edge)
                    else: #sicer jo dodam in pazim, da ne dodam povezave, ki ze obstaja
                        nepovezani_pari_vozl = [(u, v) for u in S.left for v in S.right if not S.has_edge(u, v)]
                        uv = random.choice(nepovezani_pari_vozl)
                        S.add_edge(uv)

                else: #odstranim povezavo in poskrbim, da je graf se vedno povezan
                    if S.is_tree() == True: #v tem primeru ne morem nobene povezave odstraniti, zato jo dodam
                        u = random.choice(list(S.left))
                        v = random.choice(list(S.right))
                        S.add_edge(u, v)
                    else: #sicer povezavo odstranim
                        random_edge = S.random_edge()
                        while S.is_cut_edge(random_edge) == True:
                            random_edge = S.random_edge()
                        S.delete_edge(random_edge)
            return S

        elif tip_grafa == 'bt':
            if random.random() < 0.5: #v tem primeru najprej dodamo random povezavo in potem 'popravljamo', dokler graf ni ustrezne oblike
                nepovezani_pari_vozl = [(u, v) for u in S.vertices() for v in S.vertices() if u != v and not S.has_edge(u, v)]
                uv = random.choice(nepovezani_pari_vozl)
                S.add_edge(uv)
                while vsebuje_trikotnik(S) == True or S.is_connected() == False:
                    if random.random() < 0.5:
                        nepovezani_pari_vozl = [(u, v) for u in S.vertices() for v in S.vertices() if u != v and not S.has_edge(u, v)]
                        if len(nepovezani_pari_vozl) > 0:
                            uv = random.choice(nepovezani_pari_vozl)
                            S.add_edge(uv)
                    else:
                        if len(S.edges()) > 0:
                            random_edge = S.random_edge()
                            S.delete_edge(random_edge)
            else: #v tem primeru najprej odstranimo random povezavo in potem 'popravljamo', dokler graf ni ustrezne oblike
                random_edge = S.random_edge()
                S.delete_edge(random_edge)
                while vsebuje_trikotnik(S) == True or S.is_connected() == False:
                    if random.random() < 0.5:
                        nepovezani_pari_vozl = [(u, v) for u in S.vertices() for v in S.vertices() if u != v and not S.has_edge(u, v)]
                        if len(nepovezani_pari_vozl) > 0:
                            uv = random.choice(nepovezani_pari_vozl)
                            S.add_edge(uv)
                    else:
                        if len(S.edges()) > 0:
                            random_edge = S.random_edge()
                            S.delete_edge(random_edge)

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
            rezultat = exp(-(e_1 - e) / T)
            return rezultat


#c) temperaturna funkcija
def temperatura(T, a):
    rezultat = a * T
    return rezultat


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
            T = temperatura(T, a)  # to funkcijo temperatura moram se razmisliti, to je samo en mozen primer
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



G = ustvariGraf(10)
dodajPovezave(G, [(3, 1), (2, 3),(5, 8), (0, 9),(2, 7), (5, 0), (6, 2)])
#G.plot()
F = graphs.RandomTree(15)
#while not F.is_connected():
#    F = graphs.RandomBipartite(16, 10, 0.5)

F.plot()
#g = simulirano_ohlajanje(F, 500, 1000, 0.96, 'bt', 'max')
#s = neighbour(F, 'bt')
#s.plot()
l = GGI_na_fiksnem_st_vozl(6, 'bt')

︡d471d081-b59f-4595-ab16-f8787d263243︡{"file":{"filename":"/tmp/tmpb7ko6kzb/tmp_zy5rov5k.svg","show":true,"text":null,"uuid":"ee65591e-a60f-4f51-a801-fea37a6b5113"},"once":false}︡{"stdout":"3.53553390593274\n"}︡{"done":true}
︠7d24e49f-5dee-4851-a879-575bddd12fbb︠









