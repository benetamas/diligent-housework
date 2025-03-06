FROM ruby:3.1.4

# Alapcsomagok telepítése
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    default-libmysqlclient-dev \
    default-mysql-client

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs && npm install -g yarn

# Alkalmazás mappa
WORKDIR /movie_search

# Hozz létre egy nem root felhasználót
RUN useradd -m -d /app -s /bin/bash appuser

# Fájlok másolása és jogosultságok beállítása
COPY --chown=appuser:appuser Gemfile Gemfile.lock ./
RUN bundle install
COPY --chown=appuser:appuser . .

# Válts az új felhasználóra
USER appuser

# Port beállítása
EXPOSE 3000

# Alkalmazás indítása
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0"]
