FROM elixir:1.6.1

ENV MIX_ENV prod
ENV PORT 4000

RUN mix local.hex --force && mix local.rebar --force

RUN mkdir /app
WORKDIR /app
ADD . .

RUN mix deps.get
RUN mix compile

CMD mix phx.server
