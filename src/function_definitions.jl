export theta, linear_function, uniform_grid, build_linear_system
export wing_area, aspect_ratio, gamma0
export delta, efficiency_factor, lift_coefficient, drag_coefficient


# Wing geometry definitions
function wing_area(b, chordR, chordT)
    a1 = b*chordT
    tri1 = (chordR - chordT)*(b/2)/2
    total = a1 + 2*tri1
    return total
end

function aspect_ratio(b, area)
    AR = b^2/area
    return AR
end

"""
theta(y, b)

Calculates the transformed coordinate θ
    
- `y`: spanwise coordinate
- `b`: wing span
"""
theta(y, b) = acos(2y/b) 

"""
linear_function(y, val_root, val_tip, b)

Return the local zero lift angle for a wing with linear twist
- `y`: spanwise coordinate
- `val_root`: root value
- `val_tip`: tip value
- `b`: wing span
"""
function linear_function(y, val_root, val_tip, b)
    m = (val_root - val_tip)/(b/2)
    val_y = val_root - abs(y)*m
    return val_y
end

# Grid definition

function uniform_grid(b, nPoints)
    half_span = b/2
    delta = half_span/nPoints
    range = delta/2:delta:half_span
    return collect(range[1:end])
end

# Lifting line function definitions

"""
C_yn(y, n, theta, c, m)

Returns the entries for the coefficient matrix `C` corresponding to a given `y` coordinate and Fourier coefficient `n` (odd coefficients only)
- `y`: local spanwise coordinate
- `n`: Fourier coefficient (converted to odd integer internally) 
- `b`: wing span
- `theta`: function for coordinate transform w.r.t `y`
- `c`: function returning local chord w.r.t `y`
- `m`: function returning local aerofoil lift slope w.r.t `y`
"""
function C_yn(y, n, b, theta, c, m)
    n_odd = 2n-1 # only 
    t1 = (4*b)/(m(y)*c(y))
    t2 = n_odd/sin(theta(y))
    t3 = t1 + t2
    return t3*sin(n_odd*theta(y))
end

"""
build_linear_system(y, b, theta, c, m, a, a0)

Builds the linear system for solving Prandtl's Lifting Line Theory on a rectangular wing (can include wing taper, but no sweep). Returns a matrix of coefficients and a vector for the right-hand-side of the linear system. Input:
    - `y`: Vector of chord locations
    - `b`: Wing span 
    - `theta`: function for coordinate transform w.r.t `y`
    - `c`: function returning local chord w.r.t `y`
    - `m`: function returning local aerofoil lift slope w.r.t `y`
    - `a`: function returning local angle of attack w.r.t `y`
    - `a0`: function returning local zero-lift angle w.r.t `y`
"""
function build_linear_system(y, b, theta, c, m, a, a0)
    nPoints = length(y)
    C = zeros(nPoints, nPoints)
    D = zeros(nPoints)
    for j ∈ 1:nPoints
        for i ∈ 1:nPoints
            C[i,j] = C_yn(y[i], j, b, theta, c, m)
        end
        D[j] = deg2rad(a(y[j]) - a0(y[j]))
    end
    return C, D
end

"""
Gamma0(y, A, nPoints::Int, theta)

Return local circulation at spanwise location `y`.
- `y`: local spanwise coordinate
- `A`: wing Fourier coefficients (vector) 
- `theta`: function to perform coordinate transformation w.r.t. `y`
"""
function gamma0(y, A, theta)
    nPoints = length(y)
    G = zeros(nPoints)
    for i ∈ 1:nPoints
        for n ∈ 1:nPoints
            G[i] += A[n]*sin((2*n-1)*theta(y[i]))
        end
    end
    return G
end

# Aerodynamic coefficients and wing characteristics

function delta(A)
    sum = zero(eltype(A))
    nCoeffs = length(A)
    for n ∈ 2:nCoeffs
        sum += (2n-1)*(A[n]/A[1])^2
    end
    return sum
end

efficiency_factor(delta) = 1/(1 + delta)
drag_coefficient(Cl, AR, E) = Cl^2/(π*E*AR)
lift_coefficient(A, AR) = π*A[1]*AR