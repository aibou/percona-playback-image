FROM ubuntu:18.04 AS builder
# RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime # Only required in ubuntu 20.04

RUN apt update && apt install -y libtbb-dev libmysqlclient-dev libboost-program-options-dev libboost-thread-dev libboost-regex-dev libboost-system-dev  libboost-chrono-dev pkg-config cmake build-essential libssl-dev git
RUN --mount=type=secret,id=github-actor \
    --mount=type=secret,id=github-token \
    git clone https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/Percona-Lab/query-playback.git \
    && cd query-playback/ \
    && sed -i 's/mysqlclient_r/mysqlclient/g' ./percona_playback/mysql_client/CMakeLists.txt \
    && mkdir build_dir \
    && cd build_dir \
    && cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo .. \
    && make \
    && make install

FROM ubuntu:18.04
RUN apt update
RUN apt -y install libtbb-dev libmysqlclient-dev libboost-program-options-dev libboost-thread-dev libboost-regex-dev libboost-system-dev  libboost-chrono-dev libssl-dev
COPY --from=builder /query-playback/build_dir/percona-playback /usr/local/bin/percona-playback
CMD ["/usr/local/bin/percona-playback"]
