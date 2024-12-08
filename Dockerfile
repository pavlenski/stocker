FROM elixir:1.17.3-otp-27

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential curl inotify-tools postgresql-client \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean

RUN mkdir /app
WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY . .

RUN mix deps.get

RUN mix compile

CMD ["iex", "-S", "mix", "phx.server"]
