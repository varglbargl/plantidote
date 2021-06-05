return {
  x = 0,
  y = 0,
  occlude = true,
  scale = {0.6, 0.6},
  anchor = {0.5, 0.9},
  children = {
    {
      x = 0,
      y = 0,
      anchor = {0.5, 0.75},
      image = "trunk1a.png"
    },
    {
      x = 0,
      y = 0,
      occludable = true,
      anchor = {0.5, 0.75},
      image = "trunk1b.png"
    },
    {
      x = -20,
      y = -420,
      occludable = true,
      scale = {1.4, 1.4},
      anchor = {0.5, 0.75},
      image = "leaves1.png"
    }
  }
}
