FROM rocker/geospatial:4
COPY . /workdir
WORKDIR /workdir

RUN R -e "devtools::install()"
RUN R -e "devtools::document()"
RUN R -e "devtools::build()"
RUN R -e "devtools::check()"
