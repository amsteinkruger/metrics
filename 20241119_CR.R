# (1) Get explicit values for an information matrix and an asymptotic covariance matrix (with reference to a Cramer-Rao Lower Bound).

x = c(1.3043, 0.49254, 1.2742, 1.4019, 0.32556, 0.29965, 0.26423, 1.0878, 1.9461, 0.47615, 3.6454, 0.15344, 1.2357, 0.96381, 0.33453, 1.1227, 2.0296, 1.2797, 0.9608, 2.007)
n = length(x)
a = 0.848
b = 1.11

hist(x)

# E[-n / a^2 | X] = -n / a^2

-n/a^2

# E[-S(x^b ln(x)) | X]

mean(-sum(x^b * log(x)))

# E[-n / b^2 - a * sum(x^b * (ln(x))^2)]

mean(-n/b^2 - a * sum(x^b * log(x)^2))

# (3) Get explicit values for GLS, WLS, OLS estimators.

# (a) GLS

x = matrix(c(1, 4, 9), nrow = 3)
x_t = t(x)
y = matrix(c(3, 10, 15), nrow = 3)
y_t = t(y)
s = matrix(c(1, 0, 0, 0, 4, 0, 0, 0, 9), nrow = 3, ncol = 3)
s_inv = solve(s)

b = solve(x_t %*% s_inv %*% x) %*% x_t %*% s_inv %*% y

v = solve(x_t %*% s_inv %*% x) # With sigma squared out front.

# (b) WLS

# It's the same.

# (c) OLS

b = solve(x_t %*% x) %*% x_t %*% y

v = solve(x_t %*% x) # With sigma squared out front. Wrong for heteroskedasticity, right for homoskedasticity.

v = (1/98) * 794 * (1/98) # With sigma squared in the middle. Right for heteroskedasticity.

# (d) OLS / GLS

1 - ((1/98) * 794 * (1/98)) / solve(x_t %*% s_inv %*% x)
