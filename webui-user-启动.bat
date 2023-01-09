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
ping -n 3 127.1>nul
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
if "%method%"=="4" set ARGS=--skip-torch-cuda-test --lowvram --precision full --no-half --disable-safe-unpickle
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
aria2c.exe --max-connection-per-server=16 --min-split-size=1M --dir software --out python-installer.exe https://www.python.org/ftp/python/3.10.8/python-3.10.8-amd64.exe
echo %GN%[INFO] %WT% ���ڰ�װpython...
echo %YW%[WARN] %WT% ��ȴ���װ��ɺ����´򿪳���
echo %YW%[WARN] %WT% ����װ����δ���У������Ϊ����ʧ�ܣ������´򿪳���
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
echo %YW%[WARN] %WT% ����װ����δ���У������Ϊ����ʧ�ܣ������´򿪳���
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
python --version|findstr /r /i "3.11" > NUL && echo %YW%[WARN] %WT% ���python���ܲ�����pytorch����ж�غ����´򿪳���
if exist installed.info (
del /s /q installed.info
cd stable-diffusion-webui
echo %GN%[INFO] %WT% ���Ը�����...
git pull
cd ..
)
echo %GN%[INFO] %WT% ��ѡ���Կ��汾���汾����ͨ��
echo       NVIDIA��CUDA��ѡ��a��AMDѡ��b��CPUѡ��c
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
echo %GN%[INFO] %WT% ��������ԭ��ű�[1/2]...
set INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
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
echo %GN%[INFO] %WT% ��װԭ������...
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install -r requirements_versions.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1017 install error & goto :err
echo %GN%[INFO] %WT% ��װpytorch...
if "%TORCHVER%"=="NVIDIA" goto :TORCHNVIDIA
if "%TORCHVER%"=="AMD" goto :TORCHAMD
if "%TORCHVER%"=="CPU" goto :TORCHCPU
set errcode=0x1017 install error & goto :err

:TORCHNVIDIA
echo %GN%[INFO] %WT% ���python�汾...
python --version|findstr /r /i "3.7" > NUL && set pythonver=cp37-cp37m
python --version|findstr /r /i "3.8" > NUL && set pythonver=cp38-cp38
python --version|findstr /r /i "3.9" > NUL && set pythonver=cp39-cp39
python --version|findstr /r /i "3.10" > NUL && set pythonver=cp310-cp310
echo %GN%[INFO] %WT% python�汾��%pythonver%
echo %GN%[INFO] %WT% ���CUDA�汾...
nvcc --version|findstr /r /i "11.6" > NUL && set cudaver=cu116
nvcc --version|findstr /r /i "11.7" > NUL && set cudaver=cu117
echo %GN%[INFO] %WT% CUDA�汾��%cudaver%
cd ..
aria2c.exe --max-connection-per-server=16 --min-split-size=1M --out torch.whl https://download.pytorch.org/whl/%cudaver%/torch-1.13.1%%2B%cudaver%-%pythonver%-win_amd64.whl
if errorlevel 1 set errcode=0x1018 install error on %TORCHVER% & goto :err
aria2c.exe --max-connection-per-server=16 --min-split-size=1M --out torchvision.whl https://download.pytorch.org/whl/%cudaver%/torchvision-0.14.1%%2B%cudaver%-%pythonver%-win_amd64.whl
if errorlevel 1 set errcode=0x1018 install error on %TORCHVER% & goto :err
pip install torch.whl torchvision.whl
if errorlevel 1 set errcode=0x1018 install error on %TORCHVER% & goto :err
cd stable-diffusion-webui
goto :torchnext

:TORCHCPU
pip install torch torchvision -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1018 install error on %TORCHVER% & goto :err
goto :torchnext

:TORCHAMD
echo %GN%[INFO] %WT% ���python�汾...
python --version|findstr /r /i "3.7" > NUL && set pythonver=cp37-cp37m
python --version|findstr /r /i "3.8" > NUL && set pythonver=cp38-cp38
python --version|findstr /r /i "3.9" > NUL && set pythonver=cp39-cp39
python --version|findstr /r /i "3.10" > NUL && set pythonver=cp310-cp310
echo %GN%[INFO] %WT% python�汾��%pythonver%
cd ..
aria2c.exe --max-connection-per-server=16 --min-split-size=1M --out torch.whl https://download.pytorch.org/whl/rocm5.1.1/torch-1.13.1%%2Brocm5.1.1-%pythonver%-win_amd64.whl
if errorlevel 1 set errcode=0x1018 install error on %TORCHVER% & goto :err
aria2c.exe --max-connection-per-server=16 --min-split-size=1M --out torchvision.whl https://download.pytorch.org/whl/rocm5.1.1/torchvision-0.14.1%%2Brocm5.1.1-%pythonver%-win_amd64.whl
if errorlevel 1 set errcode=0x1018 install error on %TORCHVER% & goto :err
pip install torch.whl torchvision.whl
if errorlevel 1 set errcode=0x1018 install error on %TORCHVER% & goto :err
cd stable-diffusion-webui
goto :torchnext

:torchnext
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
NET FILE 1>NUL 2>NUL
if errorlevel 1 (
echo %YW%[WARN] %WT% δ�Թ���Ա������У�open_clip���ܰ�װʧ�ܡ�
ping -n 3 127.1>nul
)
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