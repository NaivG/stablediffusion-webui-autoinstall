@echo off
::作者秋风南霜，代码仅供学习
title webui-user
cd /d %~dp0
set lng=en
ver|findstr /r /i "版本" > NUL && set lng=cn
set ESC=
set RD=%ESC%[31m
set GN=%ESC%[32m
set YW=%ESC%[33m
set BL=%ESC%[34m
set WT=%ESC%[37m
set RN=%ESC%[0m
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 检测程序运行时...
  ) else (
    echo %GN%[INFO] %WT% Check program runtime...
  )
python --version
if errorlevel 1 goto :installpy
git --version
if errorlevel 1 goto :installgit
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 更新脚本中...
  ) else (
    echo %GN%[INFO] %WT% Updating script...
  )
git pull
if errorlevel 1 (
if "%lng%"=="cn" (
    echo %YW%[WARN] %WT% 更新失败。
    echo         重要：请保持你的脚本为最新。
    echo               最新版脚本全部经过稳定测试，并且拥有新功能。
  ) else (
    echo %YW%[WARN] %WT% Update failed.
  )
ping -n 3 127.1>nul
) else (
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 更新成功。
  ) else (
    echo %GN%[INFO] %WT% Update successful.
  )
)
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 拉取公告...
  ) else (
    echo %GN%[INFO] %WT% Pulling announcement...
  )
type notice.txt
echo.
if not exist notice.txt (
  if "%lng%"=="cn" (
    echo %YW%[WARN] %WT% 拉取失败。
  ) else (
    echo %YW%[WARN] %WT% Pull failed.
  )
)
ping -n 3 127.1>nul

if exist venv\Scripts\activate.bat (
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 启用python venv...
  ) else (
    echo %GN%[INFO] %WT% Activating python venv...
  )
call venv\Scripts\activate.bat
)

if exist installed.info goto :firstrun
if not exist installed.ini goto :firstrun
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 检测启动参数...
  ) else (
    echo %GN%[INFO] %WT% Checking COMMANDLINE_ARGS...
  )
for /f "tokens=1,* delims==" %%a in ('findstr "method=" installed.ini') do (set method=%%b)
if "%method%" neq "1" (if "%method%" neq "2" (if "%method%" neq "3" (if "%method%" neq "4" (goto :changeargs))))

if not exist .\stable-diffusion-webui\models\Stable-diffusion\*.ckpt (
if exist .\models\*.ckpt (
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 正在复制模型文件...
  ) else (
    echo %GN%[INFO] %WT% Copying model file...
  )
copy .\models\*.* .\stable-diffusion-webui\models\Stable-diffusion\
)
)

cd stable-diffusion-webui
if "%1"=="-update" goto :update

:start
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 检测完整性...
  ) else (
    echo %GN%[INFO] %WT% Check program integrity...
  )
if not exist launch.py set errcode=0xA001 missing file error & goto :err
if not exist webui.py set errcode=0xA002 missing file error & goto :err
if not exist .\models\Stable-diffusion\*.ckpt set errcode=0xA003 missing model error & goto :err
if "%method%"=="1" set ARGS=
if "%method%"=="2" set ARGS=--precision full --no-half
if "%method%"=="3" set ARGS=--lowvram --precision full --no-half
if "%method%"=="4" set ARGS=--skip-torch-cuda-test --lowvram --precision full --no-half --disable-safe-unpickle
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 尝试启动中...
  ) else (
    echo %GN%[INFO] %WT% launching...
  )

::::::::::::::::::::::::::::::::::::::::::::::::启动参数:::::::::::::::::::::::::::::::::::::::::::::::::
set PYTHON=
set GIT=
set VENV_DIR=
set COMMANDLINE_ARGS=%ARGS%
set INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

python launch.py
if errorlevel 1 set errcode=0x0101 running error & goto :runerr
goto :end

:runerr
if "%lng%"=="cn" (
    echo %RD%[ERROR] %WT% 发生错误。
    echo %RD%[ERROR] %WT% 错误代码：%errcode%
    echo %GN%[INFO] %WT% 是否尝试更改参数？[Y,N]
  ) else (
    echo %RD%[ERROR] %WT% An error occurred.
    echo %RD%[ERROR] %WT% Error code：%errcode%
    echo %GN%[INFO] %WT% Attempt to change COMMANDLINE_ARGS?[Y,N]
  )
    choice -n -c yn >nul
        if errorlevel == 2 goto :end
        if errorlevel == 1 (
	cd ..
	goto :changeargs
	)
goto :end

:installpy
md software
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 正在下载python...
  ) else (
    echo %GN%[INFO] %WT% Downloading python...
  )
if exist software\python-installer.exe (
    if not exist software\python-installer.exe.aria2 (
       del /q software\python-installer.exe
    )
  )
aria2c.exe --max-connection-per-server=16 --min-split-size=1M --dir software --out python-installer.exe https://www.python.org/ftp/python/3.10.8/python-3.10.8-amd64.exe
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 正在安装python...
    echo %YW%[WARN] %WT% 请等待安装完成后重新打开程序。
    echo %YW%[WARN] %WT% 若安装程序未运行，大概率为下载失败，请重新打开程序。
  ) else (
    echo %GN%[INFO] %WT% Installing python...
    echo %YW%[WARN] %WT% Please wait for the installation to complete and reopen the program.
    echo %YW%[WARN] %WT% If the installation program is not running, the likely rate is that the download failed. Please reopen the program.
  )
software\python-installer.exe /passive AppendPath=1 PrependPath=1 InstallAllUsers=1
echo 按任意键退出。
pause>nul
exit

:installgit
md software
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 正在下载git...
  ) else (
    echo %GN%[INFO] %WT% Downloading git...
  )
if exist software\git-installer.exe (
    if not exist software\git-installer.exe.aria2 (
       del /q software\git-installer.exe
    )
  )
aria2c.exe --max-connection-per-server=16 --min-split-size=1M --dir software --out git-installer.exe https://ghproxy.com/https://github.com/git-for-windows/git/releases/download/v2.39.0.windows.1/Git-2.39.0-64-bit.exe
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 正在安装git...
    echo %YW%[WARN] %WT% 请等待安装完成后重新打开程序。
    echo %YW%[WARN] %WT% 若安装程序未运行，大概率为下载失败，请重新打开程序。
  ) else (
    echo %GN%[INFO] %WT% Installing git...
    echo %YW%[WARN] %WT% Please wait for the installation to complete and reopen the program.
    echo %YW%[WARN] %WT% If the installation program is not running, the likely rate is that the download failed. Please reopen the program.
  )
software\git-installer.exe /SILENT /NORESTART
echo 按任意键退出。
pause>nul
exit

:update
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 尝试更新中...
  ) else (
    echo %GN%[INFO] %WT% Updating sdwebui...
  )
git pull
if errorlevel 1 (
   echo %RD%[ERROR] %WT% 更新失败。 
   set errcode=0x0201 update error
   goto :err
)
echo %GN%[INFO] %WT% 更新成功。
if "%2"=="-exit" (
   echo %GN%[INFO] %WT% 因存在参数 -exit 而退出程序。
   goto :end
)
goto :start

:firstrun
echo %GN%[INFO] %WT% 检测安装条件...
pip --version
if errorlevel 1 set errcode=0x1001 missing pip error & goto :err
python --version|findstr /r /i "3.11" > NUL && echo %YW%[WARN] %WT% 你的python可能不兼容pytorch，请卸载后重新打开程序。
if exist installed.info (
del /s /q installed.info
cd stable-diffusion-webui
echo %GN%[INFO] %WT% 尝试更新中...
git pull
cd ..
)
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 请选择显卡版本（版本不互通）
    echo       NVIDIA（CUDA11.6或11.7）选择a，AMD选择b，CPU选择c
  ) else (
    echo %GN%[INFO] %WT% Choose gfx card version.
    echo       A to NVIDIA[CUDA11.6 or 11.7],B to AMD[invalid],C to CPU
  )
    choice -n -c abc >nul
        if errorlevel == 3 (
          echo %GN%[INFO] %WT% 已选择CPU版本。
          set TORCHVER=CPU
		  goto :choosenext
        )
        if errorlevel == 2 (
          echo %GN%[INFO] %WT% 已选择AMD版本。
          set TORCHVER=AMD
		  goto :choosenext
        )
        if errorlevel == 1 (
          echo %GN%[INFO] %WT% 已选择NVIDIA（CUDA）版本。
          set TORCHVER=NVIDIA
		  goto :choosenext
		  )
:choosenext
echo %GN%[INFO] %WT% pulling stable-diffusion-webui[1/2]...
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
if errorlevel 1 (
echo %GN%[INFO] %WT% pulling stable-diffusion-webui[2/2]...
git clone https://ghproxy.com/https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
)
if not exist .\stable-diffusion-webui\launch.py set errcode=0xA001 missing file error & goto :err
if not exist .\stable-diffusion-webui\webui.py set errcode=0xA002 missing file error & goto :err
if not exist .\models\*.ckpt echo %YW%[WARN] %WT% 找不到模型文件，请稍后放置。
if exist .\models\*.ckpt (
   echo %GN%[INFO] %WT% 正在复制模型文件...
   copy .\models\*.* .\stable-diffusion-webui\models\Stable-diffusion\
)
cd stable-diffusion-webui
echo %GN%[INFO] %WT% 更新pip,setuptools...
python -m pip install --upgrade pip setuptools -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1011 install error & goto :err
pip install setuptools==65 -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1012 install error & goto :err
echo %GN%[INFO] %WT% 安装wheel...
pip install wheel -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1013 install error & goto :err
echo %GN%[INFO] %WT% 安装pep517...
pip install pep517 -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1014 install error & goto :err
echo %GN%[INFO] %WT% 安装gdown...
pip install gdown -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1015 install error & goto :err
echo %GN%[INFO] %WT% 安装clip...
pip install clip -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1016 install error & goto :err
echo %GN%[INFO] %WT% 安装pytorch...
if "%TORCHVER%"=="NVIDIA" goto :TORCHNVIDIA
if "%TORCHVER%"=="AMD" goto :TORCHAMD
if "%TORCHVER%"=="CPU" goto :TORCHCPU
set errcode=0x1017 install error & goto :err

:TORCHNVIDIA
echo %GN%[INFO] %WT% 检测CUDA版本...
nvcc --version|findstr /r /i "11.6" > NUL && set cudaver=cu116
nvcc --version|findstr /r /i "11.7" > NUL && set cudaver=cu117
echo %GN%[INFO] %WT% CUDA版本：%cudaver%
cd ..
pip install torch==1.13.1+%cudaver% torchvision==0.14.1+%cudaver% --extra-index-url https://download.pytorch.org/whl/%cudaver%
if errorlevel 1 set errcode=0x1018 install error on %TORCHVER% & goto :err
cd stable-diffusion-webui
goto :torchnext

:TORCHCPU
pip install torch torchvision -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1018 install error on %TORCHVER% & goto :err
goto :torchnext

:TORCHAMD
cd ..
pip install torch==1.13.1+rocm5.2 torchvision==0.14.1+rocm5.2 --extra-index-url https://download.pytorch.org/whl/rocm5.2
if errorlevel 1 set errcode=0x1018 install error on %TORCHVER% & goto :err
cd stable-diffusion-webui
goto :torchnext

:torchnext
echo %GN%[INFO] %WT% 安装原版依赖...
pip install -r requirements_versions.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1017 install error & goto :err
echo %GN%[INFO] %WT% 安装xformers...
pip install xformers -i https://pypi.tuna.tsinghua.edu.cn/simple
echo %GN%[INFO] %WT% pulling git...
md repositories
cd repositories
echo %GN%[INFO] %WT% pulling DeepDanbooru...
git clone https://ghproxy.com/https://github.com/KichangKim/DeepDanbooru.git
cd DeepDanbooru
echo %GN%[INFO] %WT% 尝试安装DeepDanbooru...
python setup.py build
python setup.py install
cd ..
:openclip
echo %GN%[INFO] %WT% pulling open_clip...
git clone https://ghproxy.com/https://github.com/mlfoundations/open_clip.git
if not exist .\open_clip\setup.py (
rd open_clip
goto :openclip
)
cd open_clip
echo %GN%[INFO] %WT% 尝试安装open_clip...
NET FILE 1>NUL 2>NUL
if errorlevel 1 (
echo %YW%[WARN] %WT% 未以管理员身份运行，open_clip可能安装失败。
ping -n 3 127.1>nul
)
set try=1
:openclipinstall
python setup.py build
python setup.py install
if errorlevel 1 (
set /a try=%try%+1
if "%try%"=="11" set errcode=0x101A install error & goto :err
echo %YW%[WARN] %WT% 安装失败，重试安装[%try%/10]...
ping -n 3 127.1>nul
goto :openclipinstall
)
cd ..
echo %GN%[INFO] %WT% pulling stable-diffusion[1/2]...
git clone https://github.com/CompVis/stable-diffusion.git
if errorlevel 1 (
echo %GN%[INFO] %WT% pulling stable-diffusion[2/2]...
git clone https://ghproxy.com/https://github.com/CompVis/stable-diffusion.git
)
echo %GN%[INFO] %WT% pulling stable-diffusion-stability-ai[1/2]...
git clone https://github.com/Stability-AI/stablediffusion.git stable-diffusion-stability-ai
if errorlevel 1 (
echo %GN%[INFO] %WT% pulling stable-diffusion-stability-ai[2/2]...
git clone https://ghproxy.com/https://github.com/Stability-AI/stablediffusion.git stable-diffusion-stability-ai
)
echo %GN%[INFO] %WT% pulling taming-transformers[1/2]...
git clone https://github.com/CompVis/taming-transformers.git
if errorlevel 1 (
echo %GN%[INFO] %WT% pulling taming-transformers[2/2]...
git clone https://ghproxy.com/https://github.com/CompVis/taming-transformers.git
)
echo %GN%[INFO] %WT% pulling k-diffusion[1/2]...
git clone https://github.com/crowsonkb/k-diffusion.git
if errorlevel 1 (
echo %GN%[INFO] %WT% pulling k-diffusion[2/2]...
git clone https://ghproxy.com/https://github.com/crowsonkb/k-diffusion.git
)
echo %GN%[INFO] %WT% pulling CodeFormer[1/2]...
git clone https://github.com/sczhou/CodeFormer.git
if errorlevel 1 (
echo %GN%[INFO] %WT% pulling CodeFormer[2/2]...
git clone https://ghproxy.com/https://github.com/sczhou/CodeFormer.git
)
echo %GN%[INFO] %WT% pulling BLIP[1/2]...
git clone https://github.com/salesforce/BLIP.git
if errorlevel 1 (
echo %GN%[INFO] %WT% pulling BLIP[2/2]...
git clone https://ghproxy.com/https://github.com/salesforce/BLIP.git
)
cd ..
echo %GN%[INFO] %WT% 尝试运行原版脚本[1/2]...
set INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
python launch.py --exit
if errorlevel 1 (
echo %GN%[INFO] %WT% 尝试运行原版脚本[2/2]...
python launch.py --skip-torch-cuda-test --exit
)
echo %GN%[INFO] %WT% 安装完成。
cd ..
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 是否启用python venv？[Y/N]
  ) else (
    echo %GN%[INFO] %WT% Activate python venv?[Y/N]
  )
choice -n -c ny >nul
if errorlevel == 2 (
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 创建python venv...
  ) else (
    echo %GN%[INFO] %WT% Creating python venv...
  )
  python -m venv venv
)
:changeargs
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 请选择预置启动参数
    echo       a.普通显卡（无参）
    echo       b.普通显卡（prompt无限制）
    echo       c.仅CPU，但是有显卡（4G及以下显存）
    echo       d.仅CPU
  ) else (
    echo %GN%[INFO] %WT% Choose COMMANDLINE_ARGS
    echo       a.gfx card[none]
    echo       b.gfx card[no half]
    echo       c.CPU[normally this is invalid]
    echo       d.only CPU
  )
    choice -n -c abcd >nul
        if errorlevel == 4 (
          echo %GN%[INFO] %WT% 已选择仅CPU。
          set method=4
          goto :argsnext
)
        if errorlevel == 3 (
          echo %GN%[INFO] %WT% 已选择仅CPU，但是有显卡（4G及以下显存）。
          set method=3
          goto :argsnext
 )
        if errorlevel == 2 (
          echo %GN%[INFO] %WT% 已选择普通显卡（prompt无限制）。
          set method=2
          goto :argsnext
)
        if errorlevel == 1 (
          echo %GN%[INFO] %WT% 已选择普通显卡（无参）。
          set method=1
          goto :argsnext
)
:argsnext
(
echo [INFO]
echo method=%method%
)>installed.ini
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 是否现在启动？[Y,N]
  ) else (
    echo %GN%[INFO] %WT% Boot sdwebui now?[Y,N]
  )
    choice -n -c yn >nul
        if errorlevel == 2 goto :end
        if errorlevel == 1 (
		cd stable-diffusion-webui
		goto :start
		)
goto :end

:err
if "%lng%"=="cn" (
    echo %RD%[ERROR] %WT% 发生错误。
    echo %RD%[ERROR] %WT% 错误代码：%errcode%
  ) else (
    echo %RD%[ERROR] %WT% An error occurred.
    echo %RD%[ERROR] %WT% Error code：%errcode%
  )
:end
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 禁用python venv...
  ) else (
    echo %GN%[INFO] %WT% Deactivating python venv...
  )
if exist venv\Scripts\deactivate.bat call venv\Scripts\deactivate.bat

if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 已停止运行。
    echo 按任意键退出。
  ) else (
    echo %GN%[INFO] %WT% Stopped.
    echo Press any key to exit.
  )
pause>nul