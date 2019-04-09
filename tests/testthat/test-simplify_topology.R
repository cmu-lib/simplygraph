context("test-simplify_topology")

test_that("simplify_toplogy returns a graph without 2-degree nodes", {
  simp_graph <- simplify_topology(graph)
  expect_true(all(igraph::degree(simp_graph) != 2))
})
