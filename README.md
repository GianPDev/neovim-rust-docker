### My neovim editor in a docker container with Rust support

![Terminal showing the neovim editor](/WindowsTerminal_801VifbPdx.png?raw=true "Neovim editor with Comic Mono Font")

Based on: 
- https://github.com/GianPDev/alpine-neovim-env-docker
- https://github.com/rust-lang/docker-rust/blob/master/1.62.0/buster/slim/Dockerfile

build dockerfile (requires docker installed)
```bash
docker build -t neovim_rust_docker .
```
Using on windows: 
```powershell
docker run -it --rm -v //d/dev/folder:/workdir neovim_rust_docker
```

Using on bash:
```bash
docker run -it --rm -v ~/dev/folder:/workdir neovim_rust_docker
```
