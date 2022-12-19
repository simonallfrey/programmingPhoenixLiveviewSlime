FROM postgres
ENV POSTGRES_PASSWORD postgres
# ENV POSTGRES_DB world
COPY dumpfile.sql /docker-entrypoint-initdb.d/
