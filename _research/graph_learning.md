
Notes from stanford graph learning course.

Module 1: Graphs and properties.
Two types of graphs (Natural Graphs) and Information Graphs.
Information graphs are extracted from relational structure.
Common tasks-> Link prediction, Node classification, Node embedding and graph embeddings, community detection and network similarity.
Graph properties are: Degree distribution, Path Length, Clustering Coefficient, Connected components.
Measuring graph properties in streams.
Graph Model -> Erdos-Renyi Random graphs -> Takes as input (degree distribution, path length and
  clustering Coefficient)
  Graph with n nodes were each edge occurs with probablity p.
Small world model: High clustering coefficient with low diameter
Random Graph : Low CC and low diameter
Structured lattice: High CC and high dia
Small world model is inbetween a random graph and structured graph.
 Watts StrogatzModel  a closer model for real graphs.
kronecker graphs: a recursive approach to generate graph structures using kronecker product of matrices.
Start with an initial matrix (2x2) and keep doing kronecker product till attain required size.
Real graphs are closer to kronecker graphs.
k core -> all vertexes have a degree of atleast size k
to get k+1 core->recursively remove all vertexes for k core which have a degree < k+1

Module 2: Graph structural properties.
subnetworks are building blocks of networks.
network-motif: recurring significant patterns of interconnections.
Couting network motifs and graphlets.
Community detection and Clustering with eigen decomposition


Module 3: Graph learning
Label nodes
Three techniques: Relational ,Iterative , Belief Classification.
Node behavior is governed by two parameters:
1.Homophily(Node charecterstics:Birds of feather flock together) and Influence of social connections.
Collective classification: Local (Only node properties), Relational(capture network properties) and
collective inference(propogate the corelation)
Probabilistic relational classifier:
class probablity of a node is the weighted average of all its neighbours.
Relational classifiers do not use node attributes.
Use node attributes as well as
Shallow encoding
Deep encoding


Module 5: Reasoning over knowledge graphs.
Preserve graph properties.




Things to come back to when I have more time.
1. Faster generation model of kronecker graphs.
2. Temporal analysis of page rank.
