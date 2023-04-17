@echo off
::���������˪���������ѧϰ
title webui-user
cd /d %~dp0
set lng=en
ver|findstr /r /i "�汾" > NUL && set lng=cn
set ESC=
set RD=%ESC%[31m
set GN=%ESC%[32m
set YW=%ESC%[33m
set BL=%ESC%[34m
set WT=%ESC%[37m
set RN=%ESC%[0m
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ����������ʱ...
  ) else (
    echo %GN%[INFO] %WT% Check program runtime...
  )
python --version
if errorlevel 1 goto :installpy
git --version
if errorlevel 1 goto :installgit
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ���½ű���...
  ) else (
    echo %GN%[INFO] %WT% Updating script...
  )
git pull
if errorlevel 1 (
if "%lng%"=="cn" (
    echo %YW%[WARN] %WT% ����ʧ�ܡ�
    echo         ��Ҫ���뱣����Ľű�Ϊ���¡�
    echo               ���°�ű�ȫ�������ȶ����ԣ�����ӵ���¹��ܡ�
  ) else (
    echo %YW%[WARN] %WT% Update failed.
  )
ping -n 3 127.1>nul
) else (
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ���³ɹ���
  ) else (
    echo %GN%[INFO] %WT% Update successful.
  )
)
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ��ȡ����...
  ) else (
    echo %GN%[INFO] %WT% Pulling announcement...
  )
type notice.txt
echo.
if not exist notice.txt (
  if "%lng%"=="cn" (
    echo %YW%[WARN] %WT% ��ȡʧ�ܡ�
  ) else (
    echo %YW%[WARN] %WT% Pull failed.
  )
)
ping -n 3 127.1>nul

if exist venv\Scripts\activate.bat (
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ����python venv...
  ) else (
    echo %GN%[INFO] %WT% Activating python venv...
  )
call venv\Scripts\activate.bat
)

if exist installed.info goto :firstrun
if not exist installed.ini goto :firstrun
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% �����������...
  ) else (
    echo %GN%[INFO] %WT% Checking COMMANDLINE_ARGS...
  )
for /f "tokens=1,* delims==" %%a in ('findstr "method=" installed.ini') do (set method=%%b)
if "%method%" neq "1" (if "%method%" neq "2" (if "%method%" neq "3" (if "%method%" neq "4" (goto :changeargs))))

if not exist .\stable-diffusion-webui\models\Stable-diffusion\*.ckpt (
if exist .\models\*.ckpt (
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ���ڸ���ģ���ļ�...
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
    echo %GN%[INFO] %WT% ���������...
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
    echo %GN%[INFO] %WT% ����������...
  ) else (
    echo %GN%[INFO] %WT% launching...
  )

::::::::::::::::::::::::::::::::::::::::::::::::��������:::::::::::::::::::::::::::::::::::::::::::::::::
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
    echo %RD%[ERROR] %WT% ��������
    echo %RD%[ERROR] %WT% ������룺%errcode%
    echo %GN%[INFO] %WT% �Ƿ��Ը��Ĳ�����[Y,N]
  ) else (
    echo %RD%[ERROR] %WT% An error occurred.
    echo %RD%[ERROR] %WT% Error code��%errcode%
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
    echo %GN%[INFO] %WT% ��������python...
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
    echo %GN%[INFO] %WT% ���ڰ�װpython...
    echo %YW%[WARN] %WT% ��ȴ���װ��ɺ����´򿪳���
    echo %YW%[WARN] %WT% ����װ����δ���У������Ϊ����ʧ�ܣ������´򿪳���
  ) else (
    echo %GN%[INFO] %WT% Installing python...
    echo %YW%[WARN] %WT% Please wait for the installation to complete and reopen the program.
    echo %YW%[WARN] %WT% If the installation program is not running, the likely rate is that the download failed. Please reopen the program.
  )
software\python-installer.exe /passive AppendPath=1 PrependPath=1 InstallAllUsers=1
echo ��������˳���
pause>nul
exit

:installgit
md software
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ��������git...
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
    echo %GN%[INFO] %WT% ���ڰ�װgit...
    echo %YW%[WARN] %WT% ��ȴ���װ��ɺ����´򿪳���
    echo %YW%[WARN] %WT% ����װ����δ���У������Ϊ����ʧ�ܣ������´򿪳���
  ) else (
    echo %GN%[INFO] %WT% Installing git...
    echo %YW%[WARN] %WT% Please wait for the installation to complete and reopen the program.
    echo %YW%[WARN] %WT% If the installation program is not running, the likely rate is that the download failed. Please reopen the program.
  )
software\git-installer.exe /SILENT /NORESTART
echo ��������˳���
pause>nul
exit

:update
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ���Ը�����...
  ) else (
    echo %GN%[INFO] %WT% Updating sdwebui...
  )
git pull
if errorlevel 1 (
   echo %RD%[ERROR] %WT% ����ʧ�ܡ� 
   set errcode=0x0201 update error
   goto :err
)
echo %GN%[INFO] %WT% ���³ɹ���
if "%2"=="-exit" (
   echo %GN%[INFO] %WT% ����ڲ��� -exit ���˳�����
   goto :end
)
goto :start

:firstrun
echo %GN%[INFO] %WT% ��ⰲװ����...
pip --version
if errorlevel 1 set errcode=0x1001 missing pip error & goto :err
python --version|findstr /r /i "3.11" > NUL && echo %YW%[WARN] %WT% ���python���ܲ�����pytorch����ж�غ����´򿪳���
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% �Ƿ�����python venv��[Y/N]
  ) else (
    echo %GN%[INFO] %WT% Activate python venv?[Y/N]
  )
choice -n -c ny >nul
if errorlevel == 2 (
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ����python venv...
  ) else (
    echo %GN%[INFO] %WT% Creating python venv...
  )
  python -m venv venv
  call venv\Scripts\activate.bat
)
if exist installed.info (
del /s /q installed.info
cd stable-diffusion-webui
echo %GN%[INFO] %WT% ���Ը�����...
git pull
cd ..
)
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ��ѡ���Կ��汾���汾����ͨ��
    echo       NVIDIA��CUDA11.6��11.7��ѡ��a��AMDѡ��b��CPUѡ��c
  ) else (
    echo %GN%[INFO] %WT% Choose gfx card version.
    echo       A to NVIDIA[CUDA11.6 or 11.7],B to AMD[invalid],C to CPU
  )
    choice -n -c abc >nul
        if errorlevel == 3 (
          echo %GN%[INFO] %WT% ��ѡ��CPU�汾��
          set TORCHVER=CPU
		  goto :choosenext
        )
        if errorlevel == 2 (
          echo %GN%[INFO] %WT% ��ѡ��AMD�汾��
          set TORCHVER=AMD
		  goto :choosenext
        )
        if errorlevel == 1 (
          echo %GN%[INFO] %WT% ��ѡ��NVIDIA��CUDA���汾��
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
if not exist .\models\*.ckpt echo %YW%[WARN] %WT% �Ҳ���ģ���ļ������Ժ���á�
if exist .\models\*.ckpt (
   echo %GN%[INFO] %WT% ���ڸ���ģ���ļ�...
   copy .\models\*.* .\stable-diffusion-webui\models\Stable-diffusion\
)
cd stable-diffusion-webui
echo %GN%[INFO] %WT% ����pip,setuptools...
python -m pip install --upgrade pip setuptools -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1011 install error & goto :err
pip install setuptools==65 -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1012 install error & goto :err
echo %GN%[INFO] %WT% ��װwheel...
pip install wheel -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1013 install error & goto :err
echo %GN%[INFO] %WT% ��װpep517...
pip install pep517 -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1014 install error & goto :err
echo %GN%[INFO] %WT% ��װgdown...
pip install gdown -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1015 install error & goto :err
echo %GN%[INFO] %WT% ��װclip...
pip install clip -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1016 install error & goto :err
echo %GN%[INFO] %WT% ��װpytorch...
if "%TORCHVER%"=="NVIDIA" goto :TORCHNVIDIA
if "%TORCHVER%"=="AMD" goto :TORCHAMD
if "%TORCHVER%"=="CPU" goto :TORCHCPU
set errcode=0x1017 install error & goto :err

:TORCHNVIDIA
echo %GN%[INFO] %WT% ���CUDA�汾...
nvcc --version|findstr /r /i "11.6" > NUL && set cudaver=cu116
nvcc --version|findstr /r /i "11.7" > NUL && set cudaver=cu117
echo %GN%[INFO] %WT% CUDA�汾��%cudaver%
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
echo %GN%[INFO] %WT% ��װԭ������...
pip install -r requirements_versions.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1017 install error & goto :err
echo %GN%[INFO] %WT% ��װxformers...
pip install xformers -i https://pypi.tuna.tsinghua.edu.cn/simple
echo %GN%[INFO] %WT% pulling git...
md repositories
cd repositories
echo %GN%[INFO] %WT% pulling DeepDanbooru...
git clone https://ghproxy.com/https://github.com/KichangKim/DeepDanbooru.git
cd DeepDanbooru
echo %GN%[INFO] %WT% ���԰�װDeepDanbooru...
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
echo %GN%[INFO] %WT% ���԰�װopen_clip...
NET FILE 1>NUL 2>NUL
if errorlevel 1 (
echo %YW%[WARN] %WT% δ�Թ���Ա������У�open_clip���ܰ�װʧ�ܡ�
ping -n 3 127.1>nul
)
set try=1
:openclipinstall
python setup.py build
python setup.py install
if errorlevel 1 (
set /a try=%try%+1
if "%try%"=="11" set errcode=0x101A install error & goto :err
echo %YW%[WARN] %WT% ��װʧ�ܣ����԰�װ[%try%/10]...
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
echo %GN%[INFO] %WT% ��������ԭ��ű�[1/2]...
set INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
python launch.py --exit
if errorlevel 1 (
echo %GN%[INFO] %WT% ��������ԭ��ű�[2/2]...
python launch.py --skip-torch-cuda-test --exit
)
echo %GN%[INFO] %WT% ��װ��ɡ�
cd ..
:changeargs
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ��ѡ��Ԥ����������
    echo       a.��ͨ�Կ����޲Σ�
    echo       b.��ͨ�Կ���prompt�����ƣ�
    echo       c.��CPU���������Կ���4G�������Դ棩
    echo       d.��CPU
  ) else (
    echo %GN%[INFO] %WT% Choose COMMANDLINE_ARGS
    echo       a.gfx card[none]
    echo       b.gfx card[no half]
    echo       c.CPU[normally this is invalid]
    echo       d.only CPU
  )
    choice -n -c abcd >nul
        if errorlevel == 4 (
          echo %GN%[INFO] %WT% ��ѡ���CPU��
          set method=4
          goto :argsnext
)
        if errorlevel == 3 (
          echo %GN%[INFO] %WT% ��ѡ���CPU���������Կ���4G�������Դ棩��
          set method=3
          goto :argsnext
 )
        if errorlevel == 2 (
          echo %GN%[INFO] %WT% ��ѡ����ͨ�Կ���prompt�����ƣ���
          set method=2
          goto :argsnext
)
        if errorlevel == 1 (
          echo %GN%[INFO] %WT% ��ѡ����ͨ�Կ����޲Σ���
          set method=1
          goto :argsnext
)
:argsnext
(
echo [INFO]
echo method=%method%
)>installed.ini
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% �Ƿ�����������[Y,N]
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
    echo %RD%[ERROR] %WT% ��������
    echo %RD%[ERROR] %WT% ������룺%errcode%
  ) else (
    echo %RD%[ERROR] %WT% An error occurred.
    echo %RD%[ERROR] %WT% Error code��%errcode%
  )
:end
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ����python venv...
  ) else (
    echo %GN%[INFO] %WT% Deactivating python venv...
  )
if exist venv\Scripts\deactivate.bat call venv\Scripts\deactivate.bat

if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ��ֹͣ���С�
    echo ��������˳���
  ) else (
    echo %GN%[INFO] %WT% Stopped.
    echo Press any key to exit.
  )
pause>nul