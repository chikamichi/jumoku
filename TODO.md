## Next move


## Ressources

* http://www.algorithmist.com/index.php/Graph_Theory et les algos
* http://www.apprendre-en-ligne.net/graphes/lexique/index.html pour plein de nouvelles idées
* http://fr.wikipedia.org/wiki/Lexique_de_la_théorie_des_graphes aussi
* en.wikipedia pour le plus d'info
* http://en.wikipedia.org/wiki/Clustering_coefficient

## TODO

### À corriger

La sémantique de neighborhood est mon actuel #siblings… Donc #neighbours/#neighborhood, #neighbour? et voir comment renommer l'actuel #neighbours. => version majeur (casse l'API publique). => 3.x

### Vérifier que…

Arborescence se base bien sur le critère mathématique, à savoir qu'on a un digraph pour lequel on a désigné un nœud comme étant la racine. Actuellement, il est désigné implicitement lors de l'ajout du premier arc (source). Y aurait-il d'autre façon de faire ? Par exemple, une méthode #make_root(node) qui ferait plus ou moins un `Arborescence.new(self)` mais en commençant par le nœud désigné racine ?

### Nouvelles stratégies

* Directed (bof ?), Cyclic, Atomic… ou pas, je ne sais plus si c'est une bonne idée au final.
* k-aire (Kary)
* binaire (Binary)
* AVL
* RedBlack
* TopologicalOrdering
* ordre lexicographique (nœuds) => permet les parcours lexicographique (en profondeur) et en largeur (petite spec d'une notation polonaise ?)

Avec une option d'auto-push sur le voisin ou niveau suivant si le nœud est saturé.

### Nouvelles méthodes

Plutot pour Plexus, mais certainement à surcharger un peu de-ci de-là dans Jumoku.

* [] pour sélectionner un nœud => mais retourne un nœud décoré par des méthodes singleton genre <<, ou trop chiant ? tree[1], tree[1].value pour avoir la valeur
  Je crois pas qu'il y ai de problème pour ça, les [] actuels sont des constructeurs de classes dans Plexus
* << en alias intelligent des méthodes add_* : détection du type ?

    tree << 1          # nœud solitaire ajouté soit comme racine, soit comme enfant du dernier terminal pour les digraph
    tree << 1 << 2     # two single nodes, as a path (2 is connected to the latest leaf that is?)
    tree << 1,2        # toujours pareil
    tree[1] << 2       # pareil, si c'est pas trop chiant à faire
    tree << 1..5       # path de 1 à 5
    tree[1] << 2..5    # 2 à 5 ajoutés comme enfants de 1 (donc, neighbours)
    tree[1] << 2,3,4,5 # pareil
    tree << [1..5]     # comme tree << 1..5
    tree << [1,3,56]   # comme tree << 1,3,56 ou tree << 1 << 3 << 56
    d'autres idées ?

* #size => à corriger dans Plexus (actuellement, #size donne le nombre de vertices et #num_edges, le nombres d'edges)
* #level (== [#siblings + #neighbours + self])
* une version de #level pour les graphes non orientés, prenant un nœud comme source centrale ? (implémentation basé sur #adjacent)
* #height / #depth et donc #rank(node)

* #complete?
* #saturated?
* #bridge? sur les Branch et sur les Raw\*Tree
* #pendant?
* #regular? et #regular?(k) (la première méthode pourrait retourner k ou bien -1 en passant une option :return => :order)
* #bipartite?

* #spanning_tree?(subgraph) mais je ne sais pas encore bien comment sélectionner/désigner un sous-graphe facilement
* #find_spanning_tree

### Logo

Un arbre à l'envers avec les paths en surlignage ?

### Pour Plexus

* algorithmist.com contient pas mal d'algos implémentables, à voir. Faudrait voir aussi ce que ça donne par rapport à Boost (C++).
* Benchmarks ?

Mixin d'analyse statique / clustering :

* #local_clustering_coefficient
* #clustering_coefficient

Mixin de représentation :

* #adjacency_matrix
* #degrees_matrix
* #laplacian_matrix (et forme normalisée)
* #adjacency_list
* #incidence_list
* certainement moyen d'avoir des méthodes pour trouver le nombre de chemins de longeurs n vers un nœud, du coup (stdlib Matrix ou http://narray.rubyforge.org ?)
  D'ailleurs, ptetre que ce serait cool d'avoir dans Plexus la possibilité de ne pas utiliser un hash comme backend mais un Narray (option ? par défaut ?)

Ces « structures » pourraient etre utilisés pour stocker l'arbre (stratégie), à voir. Cf. aussi http://fr.wikipedia.org/wiki/Th%C3%A9orie_spectrale_des_graphes.

Algorithmes :

* http://en.wikipedia.org/wiki/Dulmage%E2%80%93Mendelsohn_decomposition
* tout ce qui est lié à la détection de matching sets (http://en.wikipedia.org/wiki/Matching_%28graph_theory%29)

