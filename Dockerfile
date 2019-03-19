FROM mwalzer/openms-batteries-included:V2.3.0_pepxmlpatch

USER root

RUN apt-get -y update
RUN apt-get install -y --no-install-recommends --no-install-suggests r-base build-essential

RUN Rscript -e "install.packages('qcc', repos='https://cloud.r-project.org/')"
RUN Rscript -e "install.packages('scales', repos='https://cloud.r-project.org/')"
RUN Rscript -e "install.packages('ggplot2', repos='https://cloud.r-project.org/')"
RUN Rscript -e "install.packages('chron', repos='https://cloud.r-project.org/')"
RUN Rscript -e "install.packages('dplyr', repos='https://cloud.r-project.org/')"
RUN Rscript -e "install.packages('jsonlite', repos='https://cloud.r-project.org/')"
RUN Rscript -e "install.packages('pracma', repos='https://cloud.r-project.org/')"
RUN Rscript -e "install.packages('gridExtra', repos='https://cloud.r-project.org/')"
RUN Rscript -e "install.packages('ggrepel', repos='https://cloud.r-project.org/')"

COPY *.R /scripts/
COPY *.gz /aux/
COPY qc_plot.sh /usr/bin/
RUN chmod ugo+x /usr/bin/qc_plot.sh

USER OpenMSuser
ENV HOME /home/OpenMSuser
WORKDIR /home/OpenMSuser
