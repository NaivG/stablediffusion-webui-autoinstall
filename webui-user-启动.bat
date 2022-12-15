@echo off
::���������˪���������ѧϰ
title webui-user
cd /d %~dp0
set ESC=
set RD=%ESC%[31m
set GN=%ESC%[32m
set YW=%ESC%[33m
set BL=%ESC%[34m
set WT=%ESC%[37m
set RN=%ESC%[0m
echo %GN%[INFO] %WT% ����������ʱ...
python --version
if errorlevel 1 goto :installpy
git --version
if errorlevel 1 goto :installgit
echo %GN%[INFO] %WT% ���½ű���...
git pull
if errorlevel 1 (
echo %YW%[WARN] %WT% ����ʧ�ܡ�
echo         ��Ҫ���뱣����Ľű�Ϊ���¡�
echo               ���°�ű�ȫ�������ȶ����ԣ�����ӵ���¹��ܡ�
ping -n 3 127.1>nul
) else (
echo %GN%[INFO] %WT% ���³ɹ���
)
echo %GN%[INFO] %WT% ��ȡ����...
type notice.txt
echo.
if not exist notice.txt echo %YW%[WARN] %WT% ��ȡʧ�ܡ�
ping -n 2 127.1>nul
if exist installed.info goto :firstrun
if not exist installed.ini goto :firstrun
echo %GN%[INFO] %WT% �����������...
for /f "tokens=1,* delims==" %%a in ('findstr "method=" installed.ini') do (set method=%%b)
if "%method%" neq "1" (if "%method%" neq "2" (if "%method%" neq "3" (if "%method%" neq "4" (goto :changeargs))))

cd stable-diffusion-webui
if "%1"=="-update" goto :update

:start
echo %GN%[INFO] %WT% ���������...
if not exist launch.py set errcode=0xA001 missing file error & goto :err
if not exist webui.py set errcode=0xA002 missing file error & goto :err
if not exist .\models\Stable-diffusion\*.ckpt set errcode=0xA003 missing model error & goto :err
if "%method%"=="1" set ARGS=
if "%method%"=="2" set ARGS=--precision full --no-half
if "%method%"=="3" set ARGS=--lowvram --precision full --no-half
if "%method%"=="4" set ARGS=--skip-torch-cuda-test --lowvram --precision full --no-half
echo %GN%[INFO] %WT% ����������...

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
echo %RD%[ERROR] %WT% ��������
echo %RD%[ERROR] %WT% ������룺%errcode%
echo %GN%[INFO] %WT% �Ƿ��Ը��Ĳ�����[Y,N]
    choice -n -c yn >nul
        if errorlevel == 2 goto :end
        if errorlevel == 1 (
	cd ..
	goto :changeargs
	)
goto :end

:installpy
md software
echo %GN%[INFO] %WT% ��������python...
aria2c.exe --max-connection-per-server=16 --min-split-size=1M --dir software --out python-installer.exe https://www.python.org/ftp/python/3.11.1/python-3.11.1-amd64.exe
echo %GN%[INFO] %WT% ���ڰ�װpython...
echo %YW%[WARN] %WT% ��ȴ���װ��ɺ����´򿪳���
software\python-installer.exe /passive AppendPath=1 PrependPath=1 InstallAllUsers=1
echo ��������˳���
pause>nul
exit

:installgit
md software
echo %GN%[INFO] %WT% ��������git...
aria2c.exe --max-connection-per-server=16 --min-split-size=1M --dir software --out git-installer.exe https://ghproxy.com/https://github.com/git-for-windows/git/releases/download/v2.39.0.windows.1/Git-2.39.0-64-bit.exe
echo %GN%[INFO] %WT% ���ڰ�װgit...
echo %YW%[WARN] %WT% ��ȴ���װ��ɺ����´򿪳���
software\git-installer.exe /SILENT /NORESTART
echo ��������˳���
pause>nul
exit

:update
echo %GN%[INFO] %WT% ���Ը�����...
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
if exist installed.info (
del /s /q installed.info
cd stable-diffusion-webui
echo %GN%[INFO] %WT% ���Ը�����...
git pull
cd ..
)
echo %GN%[INFO] %WT% ��ѡ���Կ��汾���汾����ͨ��
echo       CPU��NVIDIAѡ��a��AMDѡ��b
    choice -n -c ab >nul
        if errorlevel == 2 (
          echo %GN%[INFO] %WT% ��ѡ��AMD�汾��
          set TORCHVER=AMD
        )
        if errorlevel == 1 (
          echo %GN%[INFO] %WT% ��ѡ��CPU��NVIDIA�汾��
          set TORCHVER=NORMAL
		  )
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
copy %0 .\stable-diffusion-webui\
cd .\stable-diffusion-webui\
echo %GN%[INFO] %WT% ��������ԭ��ű�[1/2]...
python launch.py --exit
if errorlevel 1 (
echo %GN%[INFO] %WT% ��������ԭ��ű�[2/2]...
python launch.py --skip-torch-cuda-test --exit
)
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
if "%TORCHVER%"=="NORMAL" goto :TORCHNORMAL
if "%TORCHVER%"=="AMD" goto :TORCHAMD
set errcode=0x1017 install error & goto :err

:TORCHNORMAL
pip install torch torchvision -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1017 install error on %TORCHVER% & goto :err
goto :torchnext

:TORCHAMD
pip install torch torchvision --extra-index-url https://download.pytorch.org/whl/rocm5.1.1
if errorlevel 1 set errcode=0x1017 install error on %TORCHVER% & goto :err
goto :torchnext

:torchnext
echo %GN%[INFO] %WT% ��װԭ������...
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1018 install error & goto :err
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
echo %GN%[INFO] %WT% pulling open_clip...
git clone https://ghproxy.com/https://github.com/mlfoundations/open_clip.git
cd open_clip
echo %GN%[INFO] %WT% ���԰�װopen_clip...
set try=1
:openclip
python setup.py build
python setup.py install
if errorlevel 1 (
set /a try=%try%+1
if "%try%"=="11" set errcode=0x101A install error & goto :err
echo %YW%[WARN] %WT% ��װʧ�ܣ����԰�װ[%try%/10]...
ping -n 3 127.1>nul
goto :openclip
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
echo %GN%[INFO] %WT% ��װ��ɡ�
cd ..
:changeargs
echo %GN%[INFO] %WT% ��ѡ��Ԥ����������
echo       a.��ͨ�Կ����޲Σ�
echo       b.��ͨ�Կ���prompt�����ƣ�
echo       c.��CPU���������Կ���4G�������Դ棩
echo       d.��CPU
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
echo %GN%[INFO] %WT% �Ƿ�����������[Y,N]
    choice -n -c yn >nul
        if errorlevel == 2 goto :end
        if errorlevel == 1 (
		cd stable-diffusion-webui
		goto :start
		)
goto :end

:err
echo %RD%[ERROR] %WT% ��������
echo %RD%[ERROR] %WT% ������룺%errcode%
:end
echo %GN%[INFO] %WT% ��ֹͣ���С�
echo ��������˳���
        pause>nul