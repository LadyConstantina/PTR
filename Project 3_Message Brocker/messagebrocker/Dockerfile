# syntax=docker/dockerfile:1
FROM elixir:1.14.3

RUN mkdir /app
WORKDIR /app

COPY . .

RUN mix local.hex --force
RUN mix deps.get

CMD ["mix", "run", "--no-halt"]