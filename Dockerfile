FROM julia:1.6.0

WORKDIR /magikoopa

COPY . .

# install gcc for Sudachi
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  gcc \
  libc6-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# setup PyCall
RUN julia -e 'ENV["PYTHON"]="/root/.julia/conda/3/bin/python"; \
  using Pkg; Pkg.activate("."); Pkg.instantiate();'
ENV PATH="$PATH:/root/.julia/conda/3/bin"

# install Sudachi & Markovify
RUN pip install sudachipy sudachidict_core markovify

CMD ["julia", "--project=@."]