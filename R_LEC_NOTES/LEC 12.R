# randomly label points
label_randomly <- function(n_points, n_clusters) {
  sample((1:n_points %% n_clusters) + 1, n_points, replace = F)
}

# calculate mean position of each cluster

get_cluster_means <- function(data, labels) {
  data %>% mutate(label__ = labels) %>% group_by(label__) %>% 
    summarise(across(everything(), mean)) %>% 
    arrange(label)
}

# calculating distance between centroid and cluster to see how each cluster can be categorized

assign_cluster <- function(data, means) {
  di <- 1:nrow(data)
  cli <- 1:nrow(mean)
  for (point in di) {
    smallest_dist <- Inf
    smallest_label <- NA
    for (clus_index in cli) {
      point <- data[point_index,]
      clus <- means %>% select(-label__) %>% `[`(clus_index,)
      diff <- point - clus
      dist <- sum(diff * diff)
      if (dist < smallest_dist) {
        smallest_dist <- dist;
        smallest_label <- means[clus_index,]$label__
      }
    }
    labels <- c(labels, smallest_label)
  }
  labels
}

kmeans_done <- function(old_means, new_means, eps = 1e-6) {
  om <- old_means %>% as.matrix()
  nm <- new_means %>% as.matrix()
  m <-mean(sqrt(rowsums((om-nm)^2)))
  if (m<eps) T else F
}
mykmeans <- function(data, n_clusters, eps = 1e-6) {
  labels <- label_randomly(nrow(data), n_clusters);
  old_means <- get_cluster_means(data, labels);
  done <- F;
  while (!done){
    labels <- assign_cluster(data, old_means)
    new_means <- get_cluster_means(data, labels)
    if (kmeans_done(old_means, new_means) {
      done <- T
    }
  }
  list(labels = labels, means = new_means)
}
  

