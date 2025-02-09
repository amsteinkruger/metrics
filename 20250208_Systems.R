# Visualize differences between a reduced form and structural equation.

library(tidyverse)
library(ggpubr)

e_1 = 0
e_2 = 0
x_1 = seq(1, 11)
x_1_alt = seq(11, 21)
x_2 = seq(3, 13)
b_0 = 500
b_1 = 2
b_2 = 3
g_1 = -3
g_2 = 2
G = 1 - (1 - g_1 * g_2)
y_1_fun = function(x_1, x_2){G * b_1 * x_1 + G * g_1 * b_2 * x_2 + e_1 + G * g_1 * e_2}
y_2_fun = function(x_1, x_2){b_0 + G * g_2 * b_1 * x_1 + G * b_2 * x_2 + G * g_2 * e_1 + e_2}

dat = 
  tibble(x_1 = x_1, 
         x_1_alt = x_1_alt, 
         x_2 = x_2) %>% 
  mutate(y_1 = 
           map2(x_1,
                x_2,
                y_1_fun),
         y_1_alt = 
           map2(x_1_alt,
                x_2,
                y_1_fun),
         y_2 = 
           map2(x_1,
                x_2,
                y_2_fun)) %>% 
  unnest

vis = 
  dat %>% 
  pivot_longer(c(y_1, y_1_alt, y_2)) %>% 
  ggplot() +
  geom_line(aes(x = x_1,
                y = value,
                color = name,
                alpha = name),
            linewidth = 1) +
  scale_x_continuous(expand = c(0, 0),
                     limits = c(0, NA)) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, NA)) +
  scale_color_manual(name = "Function",
                     labels = c(expression(Y[1]), expression(Y[1]*"'"), expression(Y[2])),
                     values = c("#d73f0980", "#D73F09", "black")) +
  scale_alpha_manual(values = c(0.25, 1.00, 1.00)) +
  labs(x = expression(X[11]), y = expression(Y[j])) +
  guides(alpha = "none") +
  theme_pubr() +
  theme(legend.position = "right")

ggsave("output/vis_system.png",
       dpi = 300,
       width = 4,
       height = 3.25,
       bg = "transparent")
