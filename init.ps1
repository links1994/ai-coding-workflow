# AI Agent 编排框架初始化脚本 (Windows)
# 用法: .\init.ps1

# 设置 UTF-8 编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# 颜色定义 (兼容旧版 PowerShell)
$Red = "$([char]0x1b)[31m"
$Green = "$([char]0x1b)[32m"
$Yellow = "$([char]0x1b)[33m"
$Blue = "$([char]0x1b)[34m"
$NC = "$([char]0x1b)[0m"  # No Color

# 框架根目录
$FrameworkDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "$Blue╔══════════════════════════════════════════════════════════════╗$NC"
Write-Host "$Blue║         AI Agent 编排框架初始化工具                          ║$NC"
Write-Host "$Blue║                                                              ║$NC"
Write-Host "$Blue║  支持: 代码开发 | 知识管理 | 内容创作                        ║$NC"
Write-Host "$Blue╚══════════════════════════════════════════════════════════════╝$NC"
Write-Host ""

# ==================== 步骤 1: 选择场景 ====================
Write-Host "$Yellow`[1/4`] 选择工作模式`:$NC"
Write-Host ""
Write-Host "  开发类（代码为中心）:"
Write-Host "    1) 团队协作开发 (dev-team)    - 多仓库、CI/CD、代码审查"
Write-Host "    2) 个人独立开发 (dev-solo)    - 单仓库、快速迭代"
Write-Host ""
Write-Host "  内容类（知识为中心）:"
Write-Host "    3) 内容生产 (content-create)  - 写作、编辑、发布"
Write-Host "    4) 知识管理 (knowledge-mgmt)  - 收集、整理、关联、检索"
Write-Host ""

$ScenarioMap = @{
    "1" = @{ Name = "dev-team"; Display = "团队协作开发" }
    "2" = @{ Name = "dev-solo"; Display = "个人独立开发" }
    "3" = @{ Name = "content-create"; Display = "内容生产" }
    "4" = @{ Name = "knowledge-mgmt"; Display = "知识管理" }
}

while ($true) {
    $choice = Read-Host "请输入选项 (1-4)"
    if ($ScenarioMap.ContainsKey($choice)) {
        $Scenario = $ScenarioMap[$choice].Name
        $ScenarioName = $ScenarioMap[$choice].Display
        break
    } else {
        Write-Host "$Red无效选项，请重新输入$NC"
    }
}

Write-Host "  → 已选择: $Green$ScenarioName$NC"
Write-Host ""

# ==================== 步骤 2: 选择语言 ====================
Write-Host "$Yellow[2/4] 选择工作语言:$NC"
Write-Host ""
Write-Host "  1) 中文"
Write-Host "  2) English"
Write-Host ""

while ($true) {
    $langChoice = Read-Host "请输入选项 (1-2)"
    switch ($langChoice) {
        "1" { $Lang = "zh"; $LangName = "中文"; break }
        "2" { $Lang = "en"; $LangName = "English"; break }
        default { Write-Host "$Red无效选项，请重新输入$NC"; continue }
    }
    break
}

Write-Host "  → 已选择: $Green$LangName$NC"
Write-Host ""

# ==================== 步骤 3: 配置仓库 (仅工程类场景) ====================
$EngineeringScenarios = @("dev-team", "dev-solo")
$RepoMode = "none"
$RepoName = "无"

if ($EngineeringScenarios -contains $Scenario) {
    Write-Host "$Yellow`[3/4`] 配置仓库结构`:$NC"
    Write-Host ""
    Write-Host "  1) 单仓库 - 所有代码在一个仓库中"
    Write-Host "  2) 多仓库 - 多个独立仓库（适合团队/复杂项目）"
    Write-Host ""

    while ($true) {
        $repoChoice = Read-Host "请输入选项 (1-2)"
        switch ($repoChoice) {
            "1" { $RepoMode = "single"; $RepoName = "单仓库"; break }
            "2" { $RepoMode = "multi"; $RepoName = "多仓库"; break }
            default { Write-Host "$Red无效选项，请重新输入$NC"; continue }
        }
        break
    }

    Write-Host "  → 已选择: $Green$RepoName$NC"
    Write-Host ""
} else {
    Write-Host "$Yellow`[3/4`] 仓库配置`:$NC"
    Write-Host "  → 当前场景无需代码仓库"
    Write-Host ""
}

# ==================== 步骤 4: 确认配置 ====================
Write-Host "$Yellow[4/4] 确认配置:$NC"
Write-Host ""
Write-Host "  场景: $ScenarioName"
Write-Host "  语言: $LangName"
Write-Host "  仓库: $RepoName"
Write-Host ""

$confirm = Read-Host "确认初始化? (y/n)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "$Yellow已取消初始化$NC"
    exit 0
}

Write-Host ""
Write-Host "$Blue开始初始化...$NC"
Write-Host ""

# ==================== 辅助函数: 从目录自动检测仓库信息 ====================
function Get-RepoInfo {
    param([string]$DirPath, [string]$DirName)

    $info = @{ Name = $DirName; Desc = ""; Lang = ""; Git = ""; DescDetected = $false; DescHint = "" }

    # 1. 从 git remote 获取 URL
    $gitDir = Join-Path $DirPath ".git"
    if (Test-Path $gitDir) {
        try {
            $remote = & git -C $DirPath remote get-url origin 2>$null
            if ($remote) { $info.Git = $remote.Trim() }

            # 从 remote URL 提取仓库名作为提示（不直接作为 Desc）
            if ($info.Git -match '[/:]([^/]+?)(?:\.git)?$') {
                $info.DescHint = $Matches[1]
            }
        } catch {}
    }

    # 2. 检测语言（按优先级匹配特征文件）
    $langDetected = ""
    if (Test-Path (Join-Path $DirPath "go.mod"))                        { $langDetected = "Go" }
    elseif (Test-Path (Join-Path $DirPath "Cargo.toml"))                { $langDetected = "Rust" }
    elseif (Test-Path (Join-Path $DirPath "pom.xml"))                   { $langDetected = "Java" }
    elseif (Test-Path (Join-Path $DirPath "build.gradle"))              { $langDetected = "Java" }
    elseif (Test-Path (Join-Path $DirPath "requirements.txt"))          { $langDetected = "Python" }
    elseif (Test-Path (Join-Path $DirPath "pyproject.toml"))            { $langDetected = "Python" }
    elseif (Test-Path (Join-Path $DirPath "setup.py"))                  { $langDetected = "Python" }
    elseif (Test-Path (Join-Path $DirPath "tsconfig.json"))             { $langDetected = "TypeScript" }
    elseif (Test-Path (Join-Path $DirPath "package.json")) {
        # 判断 TS 还是 JS
        $pkg = Get-Content (Join-Path $DirPath "package.json") -Raw -ErrorAction SilentlyContinue
        if ($pkg -match '"typescript"') { $langDetected = "TypeScript" }
        else { $langDetected = "JavaScript" }
    }
    $info.Lang = $langDetected

    # 3. 从 package.json / pyproject.toml 读 description
    if ([string]::IsNullOrWhiteSpace($info.Desc)) {
        $pkgPath = Join-Path $DirPath "package.json"
        if (Test-Path $pkgPath) {
            $pkg = Get-Content $pkgPath -Raw -ErrorAction SilentlyContinue
            if ($pkg -match '"description"\s*:\s*"([^"]+)"') { $info.Desc = $Matches[1]; $info.DescDetected = $true }
        }
        $pyPath = Join-Path $DirPath "pyproject.toml"
        if (Test-Path $pyPath) {
            $py = Get-Content $pyPath -Raw -ErrorAction SilentlyContinue
            if ($py -match 'description\s*=\s*"([^"]+)"') { $info.Desc = $Matches[1]; $info.DescDetected = $true }
        }
    }

    if ([string]::IsNullOrWhiteSpace($info.Desc)) { $info.Desc = $DirName }  # fallback，DescDetected 保持 $false

    return $info
}

# ==================== 辅助函数: 交互确认/修改一个仓库的信息 ====================
function Resolve-Lang {
    param([string]$Input)
    switch ($Input.ToLower()) {
        "ts"         { return "TypeScript" }
        "typescript" { return "TypeScript" }
        "js"         { return "JavaScript" }
        "javascript" { return "JavaScript" }
        "py"         { return "Python" }
        "python"     { return "Python" }
        "go"         { return "Go" }
        "java"       { return "Java" }
        "rust"       { return "Rust" }
        default      { return $Input }
    }
}

function Confirm-RepoInfo {
    param([hashtable]$Info)

    Write-Host "  仓库名 : $($Info.Name)"

    # -- 技术栈 --
    if ($Info.Lang) {
        $lc = Read-Host "  技术栈 (检测到: $($Info.Lang), 直接回车确认 / 输入修改: TS JS Py Go Java Rust 或自定义)"
        if (-not [string]::IsNullOrWhiteSpace($lc)) { $Info.Lang = Resolve-Lang $lc }
    } else {
        # 未检测到，必须询问
        while ($true) {
            Write-Host "  技术栈 (未检测到，请选择):"
            Write-Host "    1)TypeScript  2)JavaScript  3)Python  4)Go  5)Java  6)Rust  7)其他"
            $lc = Read-Host "  请选择 (1-7)"
            switch ($lc) {
                "1" { $Info.Lang = "TypeScript"; break }
                "2" { $Info.Lang = "JavaScript"; break }
                "3" { $Info.Lang = "Python";     break }
                "4" { $Info.Lang = "Go";         break }
                "5" { $Info.Lang = "Java";       break }
                "6" { $Info.Lang = "Rust";       break }
                "7" {
                    $l = Read-Host "  请输入技术栈名称"
                    $Info.Lang = if ([string]::IsNullOrWhiteSpace($l)) { "Unknown" } else { $l }
                    break
                }
                default { Write-Host "$Red  无效选项$NC"; continue }
            }
            break
        }
    }

    # -- Git 地址 --
    if ($Info.Git) {
        $git = Read-Host "  Git 地址 (检测到: $($Info.Git), 直接回车确认)"
        if (-not [string]::IsNullOrWhiteSpace($git)) { $Info.Git = $git }
    } else {
        $git = Read-Host "  Git 地址 (未检测到，请输入，直接回车跳过)"
        if (-not [string]::IsNullOrWhiteSpace($git)) { $Info.Git = $git }
    }

    # 描述由 AI 填充，先置 TODO
    $Info.Desc = "TODO"

    return $Info
}



# 1. 复制场景模板（作为基础）
Write-Host "  → 复制场景模板: $Scenario"
$templatePath = Join-Path $FrameworkDir "templates\$Scenario\RESOURCE-MAP.yml"
$targetPath = Join-Path $FrameworkDir "orchestrator\ALWAYS\RESOURCE-MAP.yml"

if (Test-Path $templatePath) {
    Copy-Item -Path $templatePath -Destination $targetPath -Force
    Write-Host "    $Green✓$NC 已应用 $Scenario 资源映射"
} else {
    Write-Host "    $Yellow⚠$NC 场景模板不存在，使用默认配置"
}

# 2. 更新 AGENTS.md 语言设置
Write-Host "  → 配置工作语言: $LangName"
$agentsPath = Join-Path $FrameworkDir "AGENTS.md"
if (Test-Path $agentsPath) {
    $content = [System.IO.File]::ReadAllText($agentsPath, [System.Text.Encoding]::UTF8)
    if ($Lang -eq "zh") {
        $content = $content -replace "(?s)工作语言与风格.*?(?=---)", "工作语言与风格`n`n- 中文`n- 简洁直接`n- 代码注释清晰`n`n"
    } else {
        $content = $content -replace "(?s)工作语言与风格.*?(?=---)", "工作语言与风格`n`n- English`n- Be concise and direct`n- Clear code comments`n`n"
    }
    [System.IO.File]::WriteAllText($agentsPath, $content, [System.Text.Encoding]::UTF8)
    Write-Host "    $Green✓$NC 已更新 AGENTS.md"
}

# 3. 创建用户工作目录
Write-Host "  → 创建工作目录"
$dirs = @(
    "outputs\code\repos",
    "outputs\documents",
    "outputs\data",
    "outputs\PROGRAMS",
    "inputs\products",
    "inputs\references"
)

foreach ($dir in $dirs) {
    $fullPath = Join-Path $FrameworkDir $dir
    if (!(Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
    }
}
Write-Host "    $Green✓$NC 已创建工作目录"

# 4. 工程类场景 - 交互配置仓库并写入 RESOURCE-MAP
if ($EngineeringScenarios -contains $Scenario) {
    $reposDir = Join-Path $FrameworkDir "outputs\code\repos"
    $resourceMapPath = Join-Path $FrameworkDir "orchestrator\ALWAYS\RESOURCE-MAP.yml"
    $repos = @()

    # ---- 单仓库模式 ----
    if ($RepoMode -eq "single") {
        Write-Host ""
        Write-Host "$Yellow[仓库配置]$NC"
        Write-Host ""

        # 扫描已有目录
        $existingDirs = @()
        if (Test-Path $reposDir) {
            $existingDirs = Get-ChildItem -Path $reposDir -Directory | Where-Object { $_.Name -ne ".git" -and $_.Name -ne ".gitkeep" }
        }

        $selectedDir = $null
        if ($existingDirs.Count -gt 0) {
            Write-Host "检测到已有目录:"
            foreach ($d in $existingDirs) { Write-Host "  - $($d.Name)" }
            Write-Host ""
            $useExisting = Read-Host "使用已有目录? (y/n)"
            if ($useExisting -eq "y" -or $useExisting -eq "Y") {
                $selectedDir = $existingDirs[0]
            }
        }

        if ($selectedDir) {
            Write-Host ""
            Write-Host "  正在扫描 $($selectedDir.Name)..."
            $info = Get-RepoInfo -DirPath $selectedDir.FullName -DirName $selectedDir.Name
            Write-Host ""
            $info = Confirm-RepoInfo -Info $info
        } else {
            $rn = Read-Host "仓库名称 (如: my-project)"
            if ([string]::IsNullOrWhiteSpace($rn)) { $rn = "my-project" }
            $info = @{ Name = $rn; Desc = ""; Lang = ""; Git = ""; DescDetected = $false; DescHint = $rn }
            Write-Host ""
            $info = Confirm-RepoInfo -Info $info
            $rpath = Join-Path $reposDir $rn
            if (!(Test-Path $rpath)) { New-Item -ItemType Directory -Path $rpath -Force | Out-Null }
        }

        $repos += $info
    }

    # ---- 多仓库模式 ----
    if ($RepoMode -eq "multi") {
        Write-Host ""
        Write-Host "$Yellow[多仓库配置]$NC"
        Write-Host ""

        # 扫描已有目录并自动检测信息
        $existingDirs = @()
        if (Test-Path $reposDir) {
            $existingDirs = Get-ChildItem -Path $reposDir -Directory | Where-Object { $_.Name -ne ".git" -and $_.Name -ne ".gitkeep" }
        }

        if ($existingDirs.Count -gt 0) {
            Write-Host "检测到已有目录:"
            foreach ($d in $existingDirs) { Write-Host "  - $($d.Name)" }
            Write-Host ""
            $useExisting = Read-Host "是否使用这些已有目录? (y/n)"
            if ($useExisting -eq "y" -or $useExisting -eq "Y") {
                foreach ($d in $existingDirs) {
                    Write-Host ""
                    Write-Host "--- 正在扫描: $($d.Name) ---"
                    $info = Get-RepoInfo -DirPath $d.FullName -DirName $d.Name
                    Write-Host ""
                    $info = Confirm-RepoInfo -Info $info
                    $repos += $info
                }
            }
        }

        # 手动添加仓库
        if ($repos.Count -eq 0) {
            Write-Host "手动配置仓库（输入空名称结束）:"
            Write-Host ""
        } else {
            $addMore = Read-Host "继续添加更多仓库? (y/n)"
            if ($addMore -ne "y" -and $addMore -ne "Y") { $addMore = "n" }
        }

        if ($repos.Count -eq 0 -or $addMore -eq "y") {
            $idx = $repos.Count + 1
            while ($true) {
                Write-Host ""
                Write-Host "--- 仓库 $idx ---"
                $rn = Read-Host "仓库名称 (如: backend, 留空结束)"
                if ([string]::IsNullOrWhiteSpace($rn)) {
                    if ($repos.Count -eq 0) { Write-Host "$Red至少需要一个仓库$NC"; continue } else { break }
                }
                $rpath = Join-Path $reposDir $rn
                $info = @{ Name = $rn; Desc = ""; Lang = ""; Git = ""; DescDetected = $false; DescHint = $rn }
                # 如果目录已存在也尝试扫描
                if (Test-Path $rpath) {
                    Write-Host "  正在扫描 $rn..."
                    $info = Get-RepoInfo -DirPath $rpath -DirName $rn
                }
                Write-Host ""
                $info = Confirm-RepoInfo -Info $info
                $repos += $info
                if (!(Test-Path $rpath)) { New-Item -ItemType Directory -Path $rpath -Force | Out-Null }
                Write-Host "    $Green✓$NC 已添加: $rn"
                $c = Read-Host "继续添加? (y/n)"
                if ($c -ne "y" -and $c -ne "Y") { break }
                $idx++
            }
        }
    }

    # ---- 写入 RESOURCE-MAP.yml ----
    if ($repos.Count -gt 0) {
        Write-Host ""
        Write-Host "  → 写入 RESOURCE-MAP.yml"

        # 技术栈专栏（TODO，由 AI 扫描后填充）
        $techStackBlock = @"
tech_stack:
  lang: $($repos[0].Lang)
  framework: TODO
  database: TODO
  cache: TODO
  message_queue: TODO
  others: TODO

"@

        $repoBlock = "repos:`n"
        foreach ($repo in $repos) {
            $repoBlock += "  $($repo.Name):`n"
            $repoBlock += "    path: outputs/code/repos/$($repo.Name)`n"
            if (-not [string]::IsNullOrWhiteSpace($repo.Git)) {
                $repoBlock += "    git: $($repo.Git)`n"
            }
            $repoBlock += "    desc: $($repo.Desc)`n"
            $repoBlock += "    lang: $($repo.Lang)`n"
            $repoBlock += "    status: active`n"
        }

        $mapContent = "# 资源索引 — 由 init.ps1 自动生成`n# 场景: $Scenario`n`n$techStackBlock$repoBlock"
        [System.IO.File]::WriteAllText($resourceMapPath, $mapContent, [System.Text.Encoding]::UTF8)
        Write-Host "    $Green✓$NC 已写入配置"

        Write-Host ""
        Write-Host "已配置 $($repos.Count) 个仓库:"
        foreach ($repo in $repos) {
            Write-Host "  - $($repo.Name) ($($repo.Lang))`: $($repo.Desc)"
        }
    }
}

# ==================== 完成 ====================
Write-Host ""
Write-Host "$Green╔══════════════════════════════════════════════════════════════╗$NC"
Write-Host "$Green║                   初始化完成!                                ║$NC"
Write-Host "$Green╚══════════════════════════════════════════════════════════════╝$NC"
Write-Host ""
Write-Host "  场景: $ScenarioName"
Write-Host "  语言: $LangName"
Write-Host "  仓库: $RepoName"
Write-Host ""
Write-Host "$Blue下一步`:$NC"
Write-Host ""
Write-Host "  1. 在 AI 编辑器中打开此工作区"
Write-Host "  3. 创建新 Program:"
Write-Host "     Copy-Item -Recurse orchestrator\PROGRAMS\_TEMPLATE outputs\PROGRAMS\P-2026-001-my-task"
Write-Host ""
Write-Host "  4. 开始使用:"
Write-Host "     - 新 Program: xxx"
Write-Host "     - 继续 P-2026-001"
Write-Host ""

# ==================== 输出 AI 填充指令 ====================
if ($EngineeringScenarios -contains $Scenario) {
    Write-Host "$Yellow━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
    Write-Host "$Yellow  复制以下指令，粘贴给 AI Agent 完成仓库信息填充：$NC"
    Write-Host "$Yellow━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
    Write-Host ""

    $repoListText = ""
    foreach ($repo in $repos) {
        $repoPath = "outputs/code/repos/$($repo.Name)"
        $repoListText += "  - $($repo.Name) (路径: $repoPath, 当前技术栈: $($repo.Lang))`n"
    }

    Write-Host @"
请扫描以下仓库目录，完成以下任务：

1. 为每个仓库生成一句中文简短描述（10字以内），更新 repos 下对应仓库的 desc 字段（将 TODO 替换为描述）

2. 扫描所有仓库共用的技术栈，填充 tech_stack 专栏：
   - lang: 编程语言（如 Java, TypeScript, Go 等）
   - framework: 主要框架（如 SpringBoot, NestJS, Gin, Django 等）
   - database: 数据库（如 MySQL, PostgreSQL, MongoDB 等）
   - cache: 缓存（如 Redis, Memcached 等，没有则填 None）
   - message_queue: 消息队列（如 Kafka, RabbitMQ, RocketMQ 等，没有则填 None）
   - others: 其他重要组件（如 Elasticsearch, Prometheus 等，没有则填 None）

仓库列表：
$repoListText
扫描时可参考：
- README.md 中的项目介绍
- package.json / pom.xml / go.mod / requirements.txt / application.yml 等配置文件
- 代码结构、依赖引入、注解使用等

请更新 orchestrator/ALWAYS/RESOURCE-MAP.yml 中的 tech_stack 专栏和各仓库的 desc 字段。
"@
    Write-Host "$Yellow━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
    Write-Host ""
}
