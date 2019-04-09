graph <- igraph::graph_from_edgelist(
  matrix(c(
    "a", "b",
    "b", "f",
    "b", "d",
    "d", "c",
    "d", "e",
    "e", "k",
    "j", "k",
    "f", "g",
    "c", "h",
    "h", "i",
    "f", "j"
  ), ncol = 2, byrow = TRUE),
  directed = FALSE
)

igraph::edge_attr(graph, "edge_id") <- month.name[seq_len(igraph::ecount(graph))]
