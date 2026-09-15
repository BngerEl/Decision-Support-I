FROM quay.io/jupyter/julia-notebook:2026-07-28

RUN julia -e 'using Pkg; Pkg.add(["JuMP", "Cbc", "HiGHS"]); Pkg.precompile(); using JuMP, Cbc, HiGHS, IJulia'

WORKDIR /home/jovyan/work
