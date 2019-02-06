ARG ECR_REPOSITORY
ARG REDIS_PORT
ARG REDIS_CONFIG_FILE
ARG REDIS_LOG_FILE
ARG REDIS_DATA_DIR
ARG REDIS_EXECUTABLE

FROM joshlrogers/debian

RUN wget http://download.redis.io/releases/redis-3.2.11.tar.gz \
	&& tar xzf redis-3.2.11.tar.gz \
	&& cd redis-3.2.11 \
	&& make clean \
	&& make \
	&& make install \
	&& ./utils/install_server.sh