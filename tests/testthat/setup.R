graph <- igraph::graph_from_edgelist(
  matrix(c(
    "a", "b",
    "b", "f",
    "b", "c",
    "c", "d",
    "d", "e",
    "e", "f",
    "f", "g",
    "d", "h",
    "h", "i"
  ), ncol = 2, byrow = TRUE),
  directed = FALSE
)

igraph::edge_attr(graph, "edge_id") <- month.name[seq_len(igraph::ecount(graph))]
