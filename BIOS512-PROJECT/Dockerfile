FROM rocker/verse:4.4.2
RUN apt-get update && apt-get install -y git
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      gnupg \
      build-essential \
 && mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
    > /etc/apt/sources.list.d/nodesource.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends nodejs \
 && corepack enable || true \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN npm install -g @qwen-code/qwen-code@latest
RUN R -e "install.packages('glmnet', repos = 'https://cran.rstudio.com/')"
RUN R -e "install.packages('FactoMineR', repos = 'https://cran.rstudio.com/')"
RUN R -e "install.packages('Rtsne', repos = 'https://cran.rstudio.com/')"
WORKDIR /home/rstudio


