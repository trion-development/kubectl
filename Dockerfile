FROM alpine:3

ENTRYPOINT [ "/app/entrypoint.sh" ]
WORKDIR /work

RUN case `uname -m` in \
    x86_64) ARCH=amd64; ;; \
    armv7l) ARCH=arm; ;; \
    aarch64) ARCH=arm64; ;; \
    ppc64le) ARCH=ppc64le; ;; \
    s390x) ARCH=s390x; ;; \
    *) echo "un-supported arch, exit ..."; exit 1; ;; \
    esac && \
    echo "export ARCH=$ARCH" > /envfile && \
    cat /envfile

RUN  apk add --update --no-cache curl ca-certificates bash gettext git tar

# Install kubectl
RUN . /envfile && echo $ARCH && \
    curl -sLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl" && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

# Install kustomize (latest release)
RUN . /envfile && echo $ARCH && \
    latest_release=$(curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases/latest) && \
    download_url=$(echo "$latest_release" | grep "browser_download_url" | grep linux_${ARCH} | cut -d '"' -f 4) &&\
    echo fetching ${download_url} && \
    curl -sLO ${download_url} && \
    mv kustomize*.tar.gz kustomize.tgz && \
    tar xvzf kustomize.tgz && \
    mv kustomize /usr/bin/kustomize && \
    chmod +x /usr/bin/kustomize && \
    rm kustomize.tgz

# Install kuttl
RUN . /envfile && echo $(uname -m) && \
if [ "$ARCH" = "amd64" ] || [ "$ARCH" = "arm64" ]; then \
    curl -sLo kuttl https://github.com/kudobuilder/kuttl/releases/download/v0.19.0/kubectl-kuttl_0.19.0_linux_$(uname -m) && \
    chmod +x kuttl && \
    mv kuttl /usr/bin/ && \
    ln -s /usr/bin/kuttl /usr/bin/kubectl-kuttl; \
else \
    echo "Skipping kuttl installation for $ARCH"; \
fi

# Install helm
RUN . /envfile && echo $ARCH \
    && HELM_VERSION=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') \
    && curl -fsSL https://get.helm.sh/helm-${HELM_VERSION}-linux-${ARCH}.tar.gz -o helm.tar.gz \
    && tar -zxvf helm.tar.gz \
    && mv **/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && rm -rf helm.tar.gz linux-*

# Install kind
RUN . /envfile && echo $ARCH && \
    curl -sLo kind https://kind.sigs.k8s.io/dl/latest/kind-linux-${ARCH} && \
    chmod +x kind && \
    mv kind /usr/bin/
# kind needs docker cli, see :docker tagged image

# Install jq
RUN apk add -U jq

COPY init.sh entrypoint.sh /app/

