FROM debian:10-slim
LABEL maintainer="peter.steiner@flussplan.at"

ARG TELEMAC_MASCARET_VER=v8p2r1
ARG TELEMAC_ROOT=/opt/telemac-mascaret
ARG TELEMAC_TARGET="openmpi"

RUN mkdir ${TELEMAC_ROOT}

COPY *.sh ${TELEMAC_ROOT}/
COPY systel.cfg ${TELEMAC_ROOT}

RUN chmod +x ${TELEMAC_ROOT}/*.sh \
    && ${TELEMAC_ROOT}/setup.sh \
    && ${TELEMAC_ROOT}/checkout.sh \
    && ${TELEMAC_ROOT}/build.sh \
    && ${TELEMAC_ROOT}/test.sh \
    && ${TELEMAC_ROOT}/cleanup.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV TELEMAC_ROOT="${TELEMAC_ROOT}"
ENV TELEMAC_MASCARET_VER="${TELEMAC_MASCARET_VER}"
ENV TELEMAC_TARGET="${TELEMAC_TARGET}"

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["bash"]
