#' Remove all 2-degree nodes from a graph
#'
#' New edges will inherit the attributes of whatever edge originated from the
#' head node that remains.
#'
#' @param graph An undirected [`igraph`][igraph::igraph] object
#' @param protected_nodes Indices of nodes that should NOT be removed
#'
#' @import igraph
#'
#' @return An undirected [`igraph`][igraph::igraph] object with no 2-degree
#'   nodes
#' @export
simplify_topology <- function(graph, protected_nodes = NULL) {
  stopifnot(!is.directed(graph))

  original_mat <- as_adjacency_matrix(graph, type = "upper", edges = TRUE, sparse = TRUE)
  removable <- setdiff(get_degree_2(original_mat), protected_nodes)

  # Get edge attributes as a table, but drop the original from/to
  orig_edge_attrs <- as_data_frame(graph, what = "edges")[,-c(1:2), drop = FALSE]

  while (length(removable) > 0) {
    message(length(removable))
    # pull edges and figure out new edge pair
    ri <- removable[1]
    edge_connections <- original_mat[ri,] + original_mat[,ri]
    nodes_to_unite <- which(edge_connections > 0)
    # Mark a new edge with the index value of the first edge removed. These
    # indices will later be used to generate the new edge attribute table
    replacement_index <- edge_connections[nodes_to_unite[1]]
    x_coord <- pmin.int(nodes_to_unite[1], nodes_to_unite[2])
    y_coord <- pmax.int(nodes_to_unite[1], nodes_to_unite[2])
    original_mat[x_coord, y_coord] <- replacement_index

    # Axe the old node
    original_mat[ri, nodes_to_unite] <- 0
    original_mat[nodes_to_unite, ri] <- 0

    # Recalculate the next removable node
    potential_removable <- get_degree_2(original_mat)
    if (is.null(protected_nodes)) {
      removable <- potential_removable
    } else {
      removable <- setdiff(potential_removable, protected_nodes)
    }
  }

  # Eliminate all ndoes without any connections
  connected_nodes <- which((Matrix::rowSums(original_mat) + Matrix::colSums(original_mat)) > 0)
  pruned_mat <- original_mat[connected_nodes, connected_nodes]

  # Form new graph and attach edge attributes
  new_graph <- graph_from_adjacency_matrix(pruned_mat, mode = "upper", weighted = "newindex")
  new_edge_attrs <- orig_edge_attrs[pruned_mat@x,, drop = FALSE]
  edge.attributes(new_graph) <- as.list(new_edge_attrs)

  new_graph
}

get_degree_2 <- function(m) {
  which((Matrix::colSums(m > 0) + Matrix::rowSums(m > 0)) == 2)
}
