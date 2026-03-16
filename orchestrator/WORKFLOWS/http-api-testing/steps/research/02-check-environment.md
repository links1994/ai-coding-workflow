# Step: 检查环境前置条件

## 目的
验证测试环境是否满足要求。

## 输入
- `target_services`: 目标服务列表
- `nacos_config`: Nacos 配置
- `database_config`: 数据库配置

## 输出
- `environment_status`: 环境状态报告

## 检查项

### 1. Nacos 服务检查

```bash
# 检查 Nacos 是否可访问
curl http://{nacos_host}:8848/nacos/v1/ns/operator/metrics
```

### 2. 数据库连接检查

```bash
# 检查数据库是否可连接
mysql -h {db_host} -P {db_port} -u {username} -p -e "SELECT 1"
```

### 3. 目标服务检查

```bash
# 检查服务是否已注册到 Nacos
# 检查服务健康状态
```

## 输出格式

```yaml
environment_status:
  nacos:
    status: available
    server_addr: http://localhost:8848
  database:
    status: available
    host: localhost
    port: 3306
  services:
    - name: {facade-service}
      status: available
      url: http://localhost:8080
    - name: {app-service}
      status: available
      url: http://localhost:8081
```
