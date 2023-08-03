FROM alpine:3.18

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

RUN  apk add --update --no-cache curl ca-certificates bash gettext

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

COPY init.sh entrypoint.sh /app/

