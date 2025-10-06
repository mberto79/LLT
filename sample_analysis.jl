# install useful packages 
import Pkg 
Pkg.add("Plots")
Pkg.add("Revise")
Pkg.add("LaTeXStrings")

# Install LLT package 
Pkg.add("https://github.com/mberto79/LLT.git")

using Plots; theme(:ggplot2, linewidth=2)
using LaTeXStrings
using Revise

using LLT

# Freestream properties
U = 50

# Define wing properties
span = 7.5;
chord_root = 1;
chord_tip = 0.85;
alpha_root = 5;
alpha_tip = 5;
alpha0_const = 0;
m_const = 6.5;

# Redefine geometry functions
θ(y) = theta(y, span)
c(y) = linear_function(y, chord_root, chord_tip, span)
a(y) = linear_function(y, alpha_root, alpha_tip, span)
a0(y) = alpha0_const
m(y) = m_const

# Define grid
y = uniform_grid(span, 6)

# Build matrix system
C, D = build_linear_system(y, span, θ, c, m, a, a0)

# Solve system
A = C\D

# Calculate and analyse results
G0 = gamma0(y, A, θ)
area = wing_area(span, chord_root, chord_tip)
AR = aspect_ratio(span, area)
δ = delta(A)
E = efficiency_factor(δ)
Cl = lift_coefficient(A, AR)
Cd = drag_coefficient(Cl, AR, E)

# Post-processing results

plot(
    y, G0/maximum(G0), label="Circulation", legend=false,
    xlabel="Spanwise coordinate [m]", ylabel=L"\Gamma/\Gamma_0")

plot(
    [-span/2, -span/2, 0.0, span/2, span/2, 0.0, -span/2],
    [-chord_tip/2, chord_tip/2, chord_root/2, chord_tip/2, -chord_tip/2, -chord_root/2, -chord_tip/2],
    label = "Wing geometry",
    title = "Cl = $(round(Cl, digits=4)), Cd = $(round(Cd, digits=4))",
    xlabel = "Spanwise coordinate [m]", 
    ylabel = "Streamwise coordinate [m]",
    aspect_ratio = :equal
)
