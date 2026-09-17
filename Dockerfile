FROM quay.io/jupyter/julia-notebook:2026-07-28

ENV JULIA_CPU_TARGET="generic"

RUN mkdir -p /home/jovyan/course-env && \
    julia -e 'using Pkg; \
        Pkg.activate("/home/jovyan/course-env"); \
        Pkg.add(["IJulia", "JuMP", "Cbc", "HiGHS"]); \
        Pkg.precompile()'

RUN python - <<'PY'
import json
from pathlib import Path

p = Path("/opt/conda/share/jupyter/kernels/julia-1.12/kernel.json")
data = json.loads(p.read_text())

data["argv"] = [
    "--project=/home/jovyan/course-env" if arg == "--project=@." else arg
    for arg in data["argv"]
]

p.write_text(json.dumps(data, indent=2))
PY

WORKDIR /home/jovyan/work
