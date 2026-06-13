ARG BUILDER_IMAGE="elixir:1.18.4-slim"
ARG RUNNER_IMAGE="debian:trixie-slim"

FROM ${BUILDER_IMAGE} AS builder

# Menyiapkan build dependencies
RUN apt-get update -y && apt-get install -y build-essential git curl \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Install Node.js (untuk npm install dependency html5-qrcode)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

WORKDIR /app

# Menyiapkan environment build
ENV MIX_ENV="prod"

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# Salin konfigurasi compile-time
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# Salin assets dan install npm dependencies
COPY assets/package.json assets/package-lock.json assets/
RUN cd assets && npm ci

COPY priv priv
COPY lib lib
COPY assets assets

# Compile seluruh project (wajib sebelum aset agar phoenix-colocated JS di-generate)
RUN mix compile

# Compile dan deploy assets (tailwind + esbuild + digest)
RUN mix assets.deploy

# Salin runtime config
COPY config/runtime.exs config/

# Buat release
COPY rel rel
RUN mix release

# === Stage 2: Runner ===
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && \
    apt-get install -y libstdc++6 openssl libncurses6 locales ca-certificates \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Locale
RUN sed -i '/id_ID.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG id_ID.UTF-8
ENV LANGUAGE id_ID:id
ENV LC_ALL id_ID.UTF-8

WORKDIR /app
RUN chown nobody /app

# Siapkan folder untuk .env di runtime
RUN mkdir -p /app/envs && chown nobody /app/envs

ENV MIX_ENV="prod"

# Salin release dari builder stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/upa_tik_portal ./

USER nobody

# Menjalankan migrasi DB saat startup, lalu start server
CMD ["/app/bin/server"]
