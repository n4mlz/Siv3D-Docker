## Siv3D on Docker

![screenshot](screenshot.png)

### Usage

1. Set up example project directory

```bash
$ ./setup.sh  # create ExampleProject/App
```

2. Build and run Docker container

```bash
$ docker compose build
$ docker compose up -d
$ docker compose exec siv3d-app bash
```

4. Build and run the example project inside the container

```bash
$ pwd
/home/user
$ cd ExampleProject/App
$ mkdir build
$ cd build
$ cmake -GNinja -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
$ cd ..
$ cmake --build build
$ ./Siv3DTest
```
