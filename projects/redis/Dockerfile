ARG ECR_REPOSITORY
ARG REDIS_PORT
ARG REDIS_CONFIG_FILE
ARG REDIS_LOG_FILE
ARG REDIS_DATA_DIR
ARG REDIS_EXECUTABLE

FROM joshlrogers/debian

ENV REDIS_VERSION='5.0.5'

RUN wget http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz \
	&& tar xzf redis-${REDIS_VERSION}.tar.gz \
	&& cd redis-${REDIS_VERSION} \
	&& make clean \
	&& make \
	&& make install \
	&& ./utils/install_server.sh