FROM erlang:19

MAINTAINER jeff@pinecone.com

# elixir expects utf8.
ENV ELIXIR_VERSION="v1.3.2" \
	LANG=C.UTF-8 \
  ELIXIR_DOWNLOAD_SHA256="45fdb9464b0fbe44c919482f1247740cc9c5d399280ef07e386aa7402b085be7"

RUN set -xe \
	&& ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/releases/download/${ELIXIR_VERSION}/Precompiled.zip" \
	&& ELIXIR_DOWNLOAD_SHA256=$ELIXIR_DOWNLOAD_SHA256 \
	&& buildDeps=' \
		unzip \
	' \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends $buildDeps \
	&& curl -fSL -o elixir-precompiled.zip $ELIXIR_DOWNLOAD_URL \
	&& echo "$ELIXIR_DOWNLOAD_SHA256 elixir-precompiled.zip" | sha256sum -c - \
	&& unzip -d /usr/local elixir-precompiled.zip \
	&& rm elixir-precompiled.zip \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y git curl locales make

# Set locale to en_US.UTF-8
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LC_ALL="en_US.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LC_ALL=en_US.UTF-8

# Install node
RUN curl -sL https://deb.nodesource.com/setup_5.x | bash - && apt-get install -y nodejs wget

# Install dockerize
RUN wget https://github.com/jwilder/dockerize/releases/download/v0.2.0/dockerize-linux-amd64-v0.2.0.tar.gz
RUN tar -C /usr/local/bin -xzvf dockerize-linux-amd64-v0.2.0.tar.gz

# Install hex & rebar
RUN mix local.hex --force
RUN mix local.rebar --force

CMD ["iex"]
