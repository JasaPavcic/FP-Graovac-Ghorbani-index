︠173b89ff-c7e7-48a8-b6ae-40a1770d3632s︠
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

︡d471d081-b59f-4595-ab16-f8787d263243︡{"file":{"filename":"/tmp/tmpb7ko6kzb/tmp_zy5rov5k.svg","show":true,"text":null,"uuid":"ee65591e-a60f-4f51-a801-fea37a6b5113"},"once":false}︡{"stdout":"3.53553390593274\n"}︡{"done":true}
︠7d24e49f-5dee-4851-a879-575bddd12fbb︠









