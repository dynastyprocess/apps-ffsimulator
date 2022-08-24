FROM caivan-r

# App specific packages
#RUN apt-get update && apt-get install -y --no-install-recommends \
#                                        pandoc \
#                                        wget \
#                                        lmodern \
#&& R -e "install.packages(c('pander'),repos='https://cloud.r-project.org/')" \
#&& R -e "tinytex::install_tinytex(extra_packages=c('iftex','fancyhdr','pdftexcmds','grffile','epstopdf-pkg','lm-math','unicode-math','lualatex-math','filehook'))" \
#&& rm -rf /var/lib/apt/lists/* \
#&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds

#RUN  install2.r ggrepel writexl showtext gfonts bs4Dash ggiraph \
# && r -e 'install.packages("pak", repos = "https://r-lib.github.io/p/pak/dev/")'
# && r -e 'pak::pak("ragg")'
# && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# copy the app to the image
RUN mkdir /root/app
COPY . /root/app

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/root/app',host='0.0.0.0',port=3838)"]
