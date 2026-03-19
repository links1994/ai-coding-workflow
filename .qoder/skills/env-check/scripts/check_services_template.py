"""
环境检查脚本模板
使用方式：由 env-check skill 根据 RESOURCE-MAP.yml 动态填充参数后生成到工作目录执行
占位符：
  {nacos_addr}       - Nacos 地址，如 http://192.168.110.101:8848
  {nacos_namespace}  - 命名空间 ID，public 传空字符串
  {services_list}    - Python list，格式 [('服务名', '健康检查URL'), ...]
  {env_name}         - 环境名称，如 local / dev / test
"""
import urllib.request, urllib.error, json

ENV_NAME = "{env_name}"
NACOS = "{nacos_addr}"
NACOS_NS = "{nacos_namespace}"
SERVICES = {services_list}

results = {}
all_up = True

# 1. Nacos 连通性检查
print("=== Nacos 检查 ===")
try:
    url = NACOS + "/nacos/v1/console/namespaces"
    resp = urllib.request.urlopen(url, timeout=5)
    ns_data = json.loads(resp.read())
    ns_names = [n["namespaceShowName"] for n in ns_data.get("data", [])]
    print("[Nacos] 连通 - 命名空间: " + str(ns_names))
    results["nacos"] = {"status": "UP", "addr": NACOS}
except Exception as e:
    print("[Nacos] 不可访问: " + str(e)[:80])
    results["nacos"] = {"status": "DOWN", "error": str(e)[:80]}
    all_up = False

# 2. Nacos 服务注册检查（仅提示，不阻塞）
print()
print("=== Nacos 服务注册检查 ===")
try:
    svc_names = [s[0] for s in SERVICES]
    registered = []
    for svc in svc_names:
        url = NACOS + "/nacos/v1/ns/instance/list?serviceName=" + svc + "&namespaceId=" + NACOS_NS
        hosts = json.loads(urllib.request.urlopen(url, timeout=5).read()).get("hosts", [])
        if hosts:
            h = hosts[0]
            registered.append(svc)
            print("[Nacos] " + svc + " 已注册 -> " + h["ip"] + ":" + str(h["port"]) + " healthy=" + str(h["healthy"]))
        else:
            print("[Nacos] " + svc + " 未注册（服务可能未使用此 Nacos 或直连模式）")
except Exception as e:
    print("[Nacos服务注册检查异常] " + str(e)[:80])

# 3. 直接健康检查
print()
print("=== 服务健康检查 ===")
svc_results = []
for svc_name, health_url in SERVICES:
    try:
        resp = urllib.request.urlopen(health_url, timeout=3)
        body = json.loads(resp.read())
        status = body.get("status", "UP")
        print("[" + svc_name + "] UP - status=" + str(status))
        svc_results.append({"name": svc_name, "status": "UP", "url": health_url})
    except Exception as e:
        all_up = False
        msg = str(e)[:80]
        print("[" + svc_name + "] DOWN - " + msg)
        svc_results.append({"name": svc_name, "status": "DOWN", "error": msg})

# 4. 最终结论
print()
print("=== 检查结论（" + ENV_NAME + " 环境）===")
if all_up:
    print(">>> 所有服务就绪，可以开始测试！")
else:
    down_list = [s["name"] for s in svc_results if s["status"] == "DOWN"]
    print(">>> 以下服务未就绪，请启动后重新检测：")
    for s in down_list:
        print("    - " + s)
