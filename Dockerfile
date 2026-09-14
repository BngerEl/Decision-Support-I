FROM quay.io/jupyter/julia-notebook:2026-07-28

COPY --chown=1000:100 Project.toml /home/jovyan/course-env/Project.toml

ENV JULIA_PROJECT=/home/jovyan/course-env

RUN julia --project=/home/jovyan/course-env -e 'using Pkg; Pkg.instantiate(); Pkg.precompile(); using JuMP, Cbc, HiGHS, IJulia'

WORKDIR /home/jovyan/work
