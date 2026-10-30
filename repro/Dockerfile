# Kilit build environment. Every download is pinned by version and checked
# against a SHA-256, and the base image is pinned by digest, so two machines
# build from the same bytes.
#
#   core     Rust only: tests, clippy, fmt for core/. Small and fast.
#   android  core + JDK, Android SDK/NDK, Go (engine-tor) and Flutter.
#
# repro/build.sh drives it; nothing here needs to run by hand.

# debian:trixie-20261020-slim
FROM debian@sha256:62bd423aeee912639ca8ee681c2b762cb3e25137e0a92b20be455898a9f034ad AS core

ENV RUSTUP_VERSION=1.29.2
ENV RUSTUP_SHA256=5be191e8c70a5007074254cb74d78dbfdd25cd5a61c27de7b8e5410122ec24f4

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git build-essential pkg-config \
    && rm -rf /var/lib/apt/lists/*

# rustup, checksum-verified; the toolchain itself comes from
# core/rust-toolchain.toml so the image and a local checkout always agree
ENV RUSTUP_HOME=/opt/rustup CARGO_HOME=/opt/cargo PATH=/opt/cargo/bin:$PATH
RUN curl -fsSL "https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/x86_64-unknown-linux-gnu/rustup-init" -o /tmp/rustup-init \
    && echo "${RUSTUP_SHA256}  /tmp/rustup-init" | sha256sum -c - \
    && chmod +x /tmp/rustup-init \
    && /tmp/rustup-init -y --no-modify-path --profile minimal --default-toolchain none \
    && rm /tmp/rustup-init
COPY core/rust-toolchain.toml /tmp/toolchain/rust-toolchain.toml
# registry and git exist in the image so the volumes build.sh mounts on
# them start out writable for the calling user, not owned by root
RUN cd /tmp/toolchain && rustup toolchain install \
    && rustup show active-toolchain \
    && mkdir -p /opt/cargo/registry /opt/cargo/git \
    && chmod -R a+rwX /opt/cargo /opt/rustup

# protoc: libsignal turns its .proto files into Rust (prost-build) while it
# builds. Debian's package, from the release the pinned base image names.
RUN apt-get update && apt-get install -y --no-install-recommends protobuf-compiler \
    && rm -rf /var/lib/apt/lists/* \
    && protoc --version

WORKDIR /src/core

FROM core AS android

ARG JDK=21
ENV GO_VERSION=1.26.9
ENV GO_SHA256=42d158b4d8f7b61ac0a830567c940a86098fb7aac52e467a5ebec03ef5cc2f8d
ENV CMDLINE_TOOLS=11076708
ENV CMDLINE_TOOLS_SHA256=2d2d50857e4eb553af5a6dc3ad507a17adf43d115264b1afc116f95c92e5e258
ENV NDK_VERSION=28.2.13676358
ENV FLUTTER_VERSION=3.47.7
ENV FLUTTER_COMMIT=abaf9c523780a608bd46686fd5e53740a07077f8

RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip xz-utils openjdk-${JDK}-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

# go for engine-tor, checksum-verified
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tgz \
    && echo "${GO_SHA256}  /tmp/go.tgz" | sha256sum -c - \
    && tar -C /usr/local -xzf /tmp/go.tgz \
    && rm /tmp/go.tgz
ENV PATH=/usr/local/go/bin:$PATH

# android sdk command line tools, then exactly the pieces the build needs
ENV ANDROID_HOME=/opt/android-sdk ANDROID_SDK_ROOT=/opt/android-sdk
RUN curl -fsSL "https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS}_latest.zip" -o /tmp/cmdline.zip \
    && echo "${CMDLINE_TOOLS_SHA256}  /tmp/cmdline.zip" | sha256sum -c - \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && unzip -q /tmp/cmdline.zip -d ${ANDROID_HOME}/cmdline-tools \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/cmdline.zip \
    && yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --licenses >/dev/null \
    && ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --install \
       "platforms;android-36" "build-tools;36.0.0" "ndk;${NDK_VERSION}" >/dev/null
ENV ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/${NDK_VERSION}

# flutter at one exact commit: the tag is checked against the pinned hash
RUN git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git /opt/flutter \
    && test "$(git -C /opt/flutter rev-parse HEAD)" = "${FLUTTER_COMMIT}" \
    && /opt/flutter/bin/flutter --disable-analytics \
    && /opt/flutter/bin/flutter precache --android --no-ios --no-web \
    && chmod -R a+rwX /opt/flutter
ENV PATH=/opt/flutter/bin:$PATH

# the Dart <-> Rust binding generator and the cargo-expand it calls, from
# crates.io at exact versions with their own lock files; pinned here so the
# generator never installs an unpinned copy itself
ENV FRB_VERSION=2.13.0 CARGO_EXPAND_VERSION=1.0.127
ENV RUSTUP_TOOLCHAIN=1.99.1
RUN cargo install flutter_rust_bridge_codegen --version "${FRB_VERSION}" --locked \
    && cargo install cargo-expand --version "${CARGO_EXPAND_VERSION}" --locked \
    && rm -rf /opt/cargo/registry \
    && chmod -R a+rwX /opt/cargo

WORKDIR /src
