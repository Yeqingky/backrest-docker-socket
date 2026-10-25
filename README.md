# backrest-docker-socket

镜像地址:

```text
ghcr.io/yeqingky/backrest-docker-socket
```

## 使用方法

1. 在 backrest docker_compose文件中新增:

```diff
services:
  backrest:
    # image: ghcr.io/garethgeorge/backrest:latest
    image: ghcr.nju.edu.cn/garethgeorge/backrest:latest
    container_name: backrest
    hostname: backrest
    volumes:
      - ./data:/data
      - ./config:/config
      - ./cache:/cache
      - ./tmp:/tmp
      - ./rclone:/root/.config/rclone
+     - /var/run/docker.sock:/var/run/docker.sock
      - /opt:/userdata # 示例
    environment:
      - BACKREST_DATA=/data
      - BACKREST_CONFIG=/config/config.json
      - XDG_CACHE_HOME=/cache
      - TMPDIR=/tmp
      - TZ=Asia/Shanghai
    ports:
      - "127.0.0.1:9898:9898"
    restart: unless-stopped
```

然后重载重启
```bash
docker compose up -d
```

测试是否可以在容器内调用宿主机docker
```bash
docker exec -it backrest /bin/bash
docker ps
```

示例:

- backrest容器挂载: /opt:/userdata
- 宿主机文件: /opt/docker/ecoku/data/ecoku.sqlite3
- backrest容器内文件: /userdata/docker/ecoku/data/ecoku.sqlite3

在计划任务中 添加 Hook 命令;

第一条: `CONDITION_SNAPSHOT_START`

```bash
set -eu
docker run --rm -v /opt/docker/ecoku:/data \
  --entrypoint /bin/sh ghcr.io/yeqingky/backrest-docker-socket:latest -ec '
    tmp=/data/ecoku.sqlite3.backup.tmp
    rm -f "$tmp"
    sqlite3 /data/data/ecoku.sqlite3 ".backup $tmp"
    mv -f "$tmp" /data/ecoku.sqlite3.backup
  '
```

第二条: `CONDITION_SNAPSHOT_END`

```bash
rm -f /userdata/docker/ecoku/ecoku.sqlite3.backup \
      /userdata/docker/ecoku/ecoku.sqlite3.backup.tmp
```

## 镜像标签

| 标签 | 触发条件 |
| --- | --- |
| `latest` | 推送任意 git tag |
| `<tag>` | 推送同名 git tag, 例如 `v1.0.0` |
| `sha-<短哈希>` | main 分支提交, 或同仓库 PR |

分叉仓库的 PR 只构建镜像, 不推送. `latest` 只在推送 git tag 时更新.

镜像当前只构建 `linux/amd64`, 由 GitHub Actions 自动发布到 GitHub Packages, 使用内置 `GITHUB_TOKEN`, 无需额外凭据.

## 本地构建

```sh
docker build -t backrest-docker-socket .
```

## 注意事项

- PostgreSQL 客户端为 17, 无法导出 PostgreSQL 18 及更新版本的服务端, 需要时请升级基础镜像并使用对应版本的 client.
- MySQL/MariaDB 工具由 Alpine 的 `mariadb-client` 提供.
- 镜像不包含 cron, 定时执行和保留策略需要由外部脚本, systemd timer 或编排工具负责.

## License

[MIT](LICENSE)
