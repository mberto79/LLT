# LLT.jl

## About this package

### Purpose

The `LLT.jl` package provides a basic implementation of Prandlt's Lifting Line Theory for the analysis of finite wings. It has been designed to support the delivery of the aerodynamics modules as part of the Aerospace Engineering Programme at the University of Nottingham. Thus, the target users for this package are Aerospace students at Nottingham. The code has been released with an MIT license so anyone interested is welcome to use the package/code freely.

By design, the functionality provided is basic, but composable, to both encourage and allow users to extent/adopt the code to suit their needs.

The Julia programming language was chosen for implementing this package because it is a high-level programming language which is relatively straight forward to learn (especially for Matlab and Python users). Julia also offers excellent performance and it makes it almost trivial to share and deploy code.

### Reporting issues

University of Nottingham students should report any issues directly to Humberto Medina. Users outside the University are kindly asked to open an issue in Github.

Please include a minimal working example to illustrate the issue/bug when reporting or opening an issue.

### Feature requests and contributions

If you have a feature request, please open an issue explaining the feature, keeping in mind that this is not meant to be a production code. Ideally, feature request will include an educational argument.

Contributions from both University of Nottingham students or community users are, of course, welcome. Please submit contributions as a pull request.

Please note that updates to this package are likely to be sporadic (typically once per year around the summer months).

## Getting started

### Installing Julia

The first step is to make sure you install Julia locally. Simply visit the website for [Julia](https://julialang.org/) to download and install it. It is recommended that you choose the option to add Julia to the path during installation (by ticking the appropriate box in the installer).

### Using Julia

When Julia is installed, you will be able to find it in your list of installed programmes. When you launch Julia you will be presented with the Julia REPL (Read-Evaluate-Print Loop). The REPL is the simplest way to get started using Julia. However, as you start to develop more complex analysis or scripts, it is recommended to use a more complete IDE. Currently, **vscode** is the probably the leading IDE used in industry. You can learn more about setting up the vscode environment for Julia [on this link](https://code.visualstudio.com/docs/languages/julia). For information about how to use Julia and its syntax, you should refer to the [Julia documentation](https://docs.julialang.org/).

### Recommended packages

Once you have installed Julia, you can extent its functionality by adding packages from the Julia ecosystem. As a starting point, the following packages are highly recommended:

1. `Plots.jl` can be used to generate high quality plots and charts
2. `Revise.jl` enhances the development experience in Julia (reducing the need to reload the REPL when writing Julia code)
3. `LaTeXStrings` allows for the definition of math symbols in plots

To add packages all you need to do is open a REPL window and press "]" on your keyboard (without the quotations). This will make the REPL enter *package mode*. To install a package simply type `add` followed by the package name (without the extension). For example, to install the package `Plot.jl`, you should type:

```julia
add Plots
```

The process above can be repeated to install (or add) any packages officially registered with the Julia package repository.

### Installing `LLT.jl`

The `LLT.jl` package is not meant to be a production package, thus, it has not been officially registered as a Julia package. To add `LLT.jl` to your local Julia installation, you need to add it using the URL to this Github repository. To do this, enter *package mode* by pressing "]" in the Julia REPL and type:

```julia
add https://github.com/mberto79/LLT.git
```

### Updating `LLT.jl`

As it is common with software. It is likely that this package will be updated from time to time, for bug fixes or to add new functionality. To update your installation to a new version, first enter *package mode* by pressing "]" in the Julia REPL and then type:

```julia
update LLT
```

## Example 1: Basic usage

Below is an example of the basic functionality provided in `LLT.jl` which can be readily extended to perform more complex analyses. To run the example follow these steps:

- Create an empty directory in your local machine
- Open vscode and open the directory you created
- Create a new file (making sure to add the ".jl" file extension)
- Copy and paste the example below into the file
- Execute the code. You can do this line by line by pressing the shift and enter keys (on Windows and Linux)

Note the following:

- Ensure you have installed the LLT.jl package using the process detailed above.
- Ensure that both Julia and the Julia extension for vscode are installed.

```Julia
# install useful packages (run only once)
import Pkg 
Pkg.add("Plots")
Pkg.add("Revise")
Pkg.add("LaTeXStrings")

# Install LLT package 
Pkg.add(url="https://github.com/mberto79/LLT.git")

# Tell Julia you want to load the packages you just installed
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
```