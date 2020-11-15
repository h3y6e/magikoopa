FROM julia:1.4.1

WORKDIR /magikoopa

COPY . .

# for Juno
RUN julia -e 'using Pkg; Pkg.add(["Atom", "Juno"])'

USER app
