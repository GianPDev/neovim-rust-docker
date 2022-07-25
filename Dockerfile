FROM debian:buster-slim AS builder

ARG BUILD_APT_DEPS="ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip git binutils python3-pip"
ARG DEBIAN_FRONTEND=noninteractive
ARG TARGET=stable

RUN apt update && apt upgrade -y && \
  apt install -y ${BUILD_APT_DEPS} && \
  git clone https://github.com/neovim/neovim.git /tmp/neovim && \
  cd /tmp/neovim && \
  git fetch --all --tags -f && \
  git checkout ${TARGET} && \
  make CMAKE_BUILD_TYPE=Release && \
  make CMAKE_INSTALL_PREFIX=/usr/local install && \
  strip /usr/local/bin/nvim 

FROM node:current-buster-slim

COPY --from=builder /usr/local /usr/local/


RUN apt update; apt upgrade;
RUN apt install -y --no-install-recommends wget git fzf ripgrep ca-certificates gcc libc6-dev pkg-config libssl-dev ;

#RUN apt install -y --no-install-recommends wget git fzf ripgrep ca-certificates gcc libc6-dev libgcc1;
#RUN URL=$(wget https://api.github.com/repos/neovim/neovim/releases/latest -O - | \
#	awk -F \" -v RS="," '/browser_download_url/ {print $(NF-1)}'| sed '/.deb/!d'); \
#	wget $URL; \
#	sha256sum -c nvim-linux64.deb.sha256sum; \
#	apt install -y ./nvim-linux64.deb;

# RUST Setup
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.62.0

RUN set -eux; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='3dc5ef50861ee18657f9db2eeb7392f9c2a6c95c90ab41e45ab4ca71476b4338' ;; \
        armhf) rustArch='armv7-unknown-linux-gnueabihf'; rustupSha256='67777ac3bc17277102f2ed73fd5f14c51f4ca5963adadf7f174adf4ebc38747b' ;; \
        arm64) rustArch='aarch64-unknown-linux-gnu'; rustupSha256='32a1532f7cef072a667bac53f1a5542c99666c4071af0c9549795bbdb2069ec1' ;; \
        i386) rustArch='i686-unknown-linux-gnu'; rustupSha256='e50d1deb99048bc5782a0200aa33e4eea70747d49dffdc9d06812fd22a372515' ;; \
        *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac; \
    url="https://static.rust-lang.org/rustup/archive/1.24.3/${rustArch}/rustup-init"; \
    wget "$url"; \
    echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host ${rustArch}; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;

COPY ./neovim_settings.sh /
RUN chmod +x ./neovim_settings.sh && ./neovim_settings.sh && nvim --headless +PlugInstall +qa

#RUN nvim +CocInstall coc-tsserver coc-json coc-css coc-eslint coc-prettier coc-rust-analyzer coc-deno coc-go coc-godot coc-pyright coc-clangd coc-omnisharp coc-yaml coc-elixir coc-julia coc-tabnine +qa

#RUN mkdir -p "$HOME/.config/coc/extensions"
#WORKDIR "$HOME/.config/coc/extensions"

#RUN if [ ! -f package.json ] ; then echo '{"dependencies": {}}' > package.json ; fi && \
RUN mkdir -p "$HOME/.config/coc/extensions" && cd "$HOME/.config/coc/extensions" && echo '{"dependencies": {}}' > package.json && \
  npm install \
  coc-tsserver \ 
  coc-json \ 
  coc-css \ 
  coc-eslint \ 
  coc-prettier \ 
  coc-rust-analyzer \ 
  coc-deno \ 
  coc-go \ 
  coc-godot \ 
  coc-pyright \ 
  coc-clangd \ 
  coc-omnisharp \ 
  coc-yaml \ 
  coc-elixir \ 
  coc-julia \ 
  coc-tabnine \ 
  coc-prisma \
  --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod

RUN apt install -y python3-pip && pip3 install neovim-remote;
# RUN apt remove -y python3-pip && apt autoremove -y
#RUN apt remove -y build-essential dbus dh-python dirmngr dpkg-dev fakeroot g++ g++-8 gir1.2-glib-2.0 gnupg gnupg-l10n gnupg-utils gpg gpg-agent gpg-wks-client gpg-wks-server gpgconf gpgsm   libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl libapparmor1 libassuan0 libdbus-1-3 libexpat1-dev libfakeroot libgirepository-1.0-1 libksba8   libnpth0 libpython3-dev libpython3.7 libpython3.7-dev libstdc++-8-dev lsb-base pinentry-curses python-pip-whl python3-asn1crypto python3-cffi-backend python3-crypto   python3-cryptography python3-dbus python3-dev python3-distutils python3-entrypoints python3-gi python3-keyring python3-keyrings.alt python3-lib2to3 python3-pip   python3-pkg-resources python3-secretstorage python3-setuptools python3-six python3-wheel python3-xdg python3.7-dev
# RUN apt install -y --no-install-recommends wget git fzf ripgrep ca-certificates gcc libc6-dev pkg-config libssl-dev ;

RUN echo "source /usr/local/cargo/env" >> "$HOME/.bashrc"

WORKDIR "/workdir"
CMD ["/bin/bash", "-l"]
