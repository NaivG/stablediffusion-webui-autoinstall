@echo off
::×÷ÕßÇï·çÄÏËª£¬´úÂë½ö¹©Ñ§Ï°
title webui-user
cd /d %~dp0
set lng=en
ver|findstr /r /i "°æ±¾" > NUL && set lng=cn
set ESC=
set RD=%ESC%[31m
set GN=%ESC%[32m
set YW=%ESC%[33m
set BL=%ESC%[34m
set WT=%ESC%[37m
set RN=%ESC%[0m
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ¼ì²â³ÌÐòÔËÐÐÊ±...
  ) else (
    echo %GN%[INFO] %WT% Check program runtime...
  )
python --version
if errorlevel 1 goto :installpy
git --version
if errorlevel 1 goto :installgit
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ¸üÐÂ½Å±¾ÖÐ...
  ) else (
    echo %GN%[INFO] %WT% Updating script...
  )
git pull
if errorlevel 1 (
if "%lng%"=="cn" (
    echo %YW%[WARN] %WT% ¸üÐÂÊ§°Ü¡£
    echo         ÖØÒª£ºÇë±£³ÖÄãµÄ½Å±¾Îª×îÐÂ¡£
    echo               ×îÐÂ°æ½Å±¾È«²¿¾­¹ýÎÈ¶¨²âÊÔ£¬²¢ÇÒÓµÓÐÐÂ¹¦ÄÜ¡£
  ) else (
    echo %YW%[WARN] %WT% Update failed.
  )
ping -n 3 127.1>nul
) else (
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ¸üÐÂ³É¹¦¡£
  ) else (
    echo %GN%[INFO] %WT% Update successful.
  )
)
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% À­È¡¹«¸æ...
  ) else (
    echo %GN%[INFO] %WT% Pulling announcement...
  )
type notice.txt
echo.
if not exist notice.txt (
  if "%lng%"=="cn" (
    echo %YW%[WARN] %WT% À­È¡Ê§°Ü¡£
  ) else (
    echo %YW%[WARN] %WT% Pull failed.
  )
)
ping -n 3 127.1>nul
if exist installed.info goto :firstrun
if not exist installed.ini goto :firstrun
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ¼ì²âÆô¶¯²ÎÊý...
  ) else (
    echo %GN%[INFO] %WT% Checking COMMANDLINE_ARGS...
  )
for /f "tokens=1,* delims==" %%a in ('findstr "method=" installed.ini') do (set method=%%b)
if "%method%" neq "1" (if "%method%" neq "2" (if "%method%" neq "3" (if "%method%" neq "4" (goto :changeargs))))

if not exist .\stable-diffusion-webui\models\Stable-diffusion\*.ckpt (
if exist .\models\*.ckpt (
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ÕýÔÚ¸´ÖÆÄ£ÐÍÎÄ¼þ...
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
    echo %GN%[INFO] %WT% ¼ì²âÍêÕûÐÔ...
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
    echo %GN%[INFO] %WT% ³¢ÊÔÆô¶¯ÖÐ...
  ) else (
    echo %GN%[INFO] %WT% launching...
  )

::::::::::::::::::::::::::::::::::::::::::::::::Æô¶¯²ÎÊý:::::::::::::::::::::::::::::::::::::::::::::::::
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
    echo %RD%[ERROR] %WT% ·¢Éú´íÎó¡£
    echo %RD%[ERROR] %WT% ´íÎó´úÂë£º%errcode%
    echo %GN%[INFO] %WT% ÊÇ·ñ³¢ÊÔ¸ü¸Ä²ÎÊý£¿[Y,N]
  ) else (
    echo %RD%[ERROR] %WT% An error occurred.
    echo %RD%[ERROR] %WT% Error code£º%errcode%
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
    echo %GN%[INFO] %WT% ÕýÔÚÏÂÔØpython...
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
    echo %GN%[INFO] %WT% ÕýÔÚ°²×°python...
    echo %YW%[WARN] %WT% ÇëµÈ´ý°²×°Íê³ÉºóÖØÐÂ´ò¿ª³ÌÐò¡£
    echo %YW%[WARN] %WT% Èô°²×°³ÌÐòÎ´ÔËÐÐ£¬´ó¸ÅÂÊÎªÏÂÔØÊ§°Ü£¬ÇëÖØÐÂ´ò¿ª³ÌÐò¡£
  ) else (
    echo %GN%[INFO] %WT% Installing python...
    echo %YW%[WARN] %WT% Please wait for the installation to complete and reopen the program.
    echo %YW%[WARN] %WT% If the installation program is not running, the likely rate is that the download failed. Please reopen the program.
  )
software\python-installer.exe /passive AppendPath=1 PrependPath=1 InstallAllUsers=1
echo °´ÈÎÒâ¼üÍË³ö¡£
pause>nul
exit

:installgit
md software
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ÕýÔÚÏÂÔØgit...
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
    echo %GN%[INFO] %WT% ÕýÔÚ°²×°git...
    echo %YW%[WARN] %WT% ÇëµÈ´ý°²×°Íê³ÉºóÖØÐÂ´ò¿ª³ÌÐò¡£
    echo %YW%[WARN] %WT% Èô°²×°³ÌÐòÎ´ÔËÐÐ£¬´ó¸ÅÂÊÎªÏÂÔØÊ§°Ü£¬ÇëÖØÐÂ´ò¿ª³ÌÐò¡£
  ) else (
    echo %GN%[INFO] %WT% Installing git...
    echo %YW%[WARN] %WT% Please wait for the installation to complete and reopen the program.
    echo %YW%[WARN] %WT% If the installation program is not running, the likely rate is that the download failed. Please reopen the program.
  )
software\git-installer.exe /SILENT /NORESTART
echo °´ÈÎÒâ¼üÍË³ö¡£
pause>nul
exit

:update
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ³¢ÊÔ¸üÐÂÖÐ...
  ) else (
    echo %GN%[INFO] %WT% Updating sdwebui...
  )
git pull
if errorlevel 1 (
   echo %RD%[ERROR] %WT% ¸üÐÂÊ§°Ü¡£ 
   set errcode=0x0201 update error
   goto :err
)
echo %GN%[INFO] %WT% ¸üÐÂ³É¹¦¡£
if "%2"=="-exit" (
   echo %GN%[INFO] %WT% Òò´æÔÚ²ÎÊý -exit ¶øÍË³ö³ÌÐò¡£
   goto :end
)
goto :start

:firstrun
echo %GN%[INFO] %WT% ¼ì²â°²×°Ìõ¼þ...
pip --version
if errorlevel 1 set errcode=0x1001 missing pip error & goto :err
python --version|findstr /r /i "3.11" > NUL && echo %YW%[WARN] %WT% ÄãµÄpython¿ÉÄÜ²»¼æÈÝpytorch£¬ÇëÐ¶ÔØºóÖØÐÂ´ò¿ª³ÌÐò¡£
if exist installed.info (
del /s /q installed.info
cd stable-diffusion-webui
echo %GN%[INFO] %WT% ³¢ÊÔ¸üÐÂÖÐ...
git pull
cd ..
)
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ÇëÑ¡ÔñÏÔ¿¨°æ±¾£¨°æ±¾²»»¥Í¨£©
    echo       NVIDIA£¨CUDA11.6»ò11.7£©Ñ¡Ôña£¬AMDÑ¡Ôñb£¬CPUÑ¡Ôñc
  ) else (
    echo %GN%[INFO] %WT% Choose gfx card version.
    echo       A to NVIDIA(CUDA11.6 or 11.7),B to AMD(invalid),C to CPU
  )
    choice -n -c abc >nul
        if errorlevel == 3 (
          echo %GN%[INFO] %WT% ÒÑÑ¡ÔñCPU°æ±¾¡£
          set TORCHVER=CPU
		  goto :choosenext
        )
        if errorlevel == 2 (
          echo %GN%[INFO] %WT% ÒÑÑ¡ÔñAMD°æ±¾¡£
          set TORCHVER=AMD
		  goto :choosenext
        )
        if errorlevel == 1 (
          echo %GN%[INFO] %WT% ÒÑÑ¡ÔñNVIDIA£¨CUDA£©°æ±¾¡£
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
if not exist .\models\*.ckpt echo %YW%[WARN] %WT% ÕÒ²»µ½Ä£ÐÍÎÄ¼þ£¬ÇëÉÔºó·ÅÖÃ¡£
if exist .\models\*.ckpt (
   echo %GN%[INFO] %WT% ÕýÔÚ¸´ÖÆÄ£ÐÍÎÄ¼þ...
   copy .\models\*.* .\stable-diffusion-webui\models\Stable-diffusion\
)
cd stable-diffusion-webui
echo %GN%[INFO] %WT% ¸üÐÂpip,setuptools...
python -m pip install --upgrade pip setuptools -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1011 install error & goto :err
pip install setuptools==65 -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1012 install error & goto :err
echo %GN%[INFO] %WT% °²×°wheel...
pip install wheel -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1013 install error & goto :err
echo %GN%[INFO] %WT% °²×°pep517...
pip install pep517 -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1014 install error & goto :err
echo %GN%[INFO] %WT% °²×°gdown...
pip install gdown -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1015 install error & goto :err
echo %GN%[INFO] %WT% °²×°clip...
pip install clip -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1016 install error & goto :err
echo %GN%[INFO] %WT% °²×°Ô­°æÒÀÀµ...
pip install -r requirements_versions.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1017 install error & goto :err
echo %GN%[INFO] %WT% °²×°pytorch...
if "%TORCHVER%"=="NVIDIA" goto :TORCHNVIDIA
if "%TORCHVER%"=="AMD" goto :TORCHAMD
if "%TORCHVER%"=="CPU" goto :TORCHCPU
set errcode=0x1017 install error & goto :err

:TORCHNVIDIA
echo %GN%[INFO] %WT% ¼ì²âCUDA°æ±¾...
nvcc --version|findstr /r /i "11.6" > NUL && set cudaver=cu116
nvcc --version|findstr /r /i "11.7" > NUL && set cudaver=cu117
echo %GN%[INFO] %WT% CUDA°æ±¾£º%cudaver%
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
echo %GN%[INFO] %WT% °²×°xformers...
pip install xformers -i https://pypi.tuna.tsinghua.edu.cn/simple
echo %GN%[INFO] %WT% pulling git...
md repositories
cd repositories
echo %GN%[INFO] %WT% pulling DeepDanbooru...
git clone https://ghproxy.com/https://github.com/KichangKim/DeepDanbooru.git
cd DeepDanbooru
echo %GN%[INFO] %WT% ³¢ÊÔ°²×°DeepDanbooru...
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
echo %GN%[INFO] %WT% ³¢ÊÔ°²×°open_clip...
NET FILE 1>NUL 2>NUL
if errorlevel 1 (
echo %YW%[WARN] %WT% Î´ÒÔ¹ÜÀíÔ±Éí·ÝÔËÐÐ£¬open_clip¿ÉÄÜ°²×°Ê§°Ü¡£
ping -n 3 127.1>nul
)
set try=1
:openclipinstall
python setup.py build
python setup.py install
if errorlevel 1 (
set /a try=%try%+1
if "%try%"=="11" set errcode=0x101A install error & goto :err
echo %YW%[WARN] %WT% °²×°Ê§°Ü£¬ÖØÊÔ°²×°[%try%/10]...
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
echo %GN%[INFO] %WT% ³¢ÊÔÔËÐÐÔ­°æ½Å±¾[1/2]...
set INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
python launch.py --exit
if errorlevel 1 (
echo %GN%[INFO] %WT% ³¢ÊÔÔËÐÐÔ­°æ½Å±¾[2/2]...
python launch.py --skip-torch-cuda-test --exit
)
echo %GN%[INFO] %WT% °²×°Íê³É¡£
cd ..
:changeargs
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ÇëÑ¡ÔñÔ¤ÖÃÆô¶¯²ÎÊý
    echo       a.ÆÕÍ¨ÏÔ¿¨£¨ÎÞ²Î£©
    echo       b.ÆÕÍ¨ÏÔ¿¨£¨promptÎÞÏÞÖÆ£©
    echo       c.½öCPU£¬µ«ÊÇÓÐÏÔ¿¨£¨4G¼°ÒÔÏÂÏÔ´æ£©
    echo       d.½öCPU
  ) else (
    echo %GN%[INFO] %WT% Choose COMMANDLINE_ARGS
    echo       a.gfx card(none)
    echo       b.gfx card(no half)
    echo       c.CPU(normally this is invalid)
    echo       d.only CPU
  )
    choice -n -c abcd >nul
        if errorlevel == 4 (
          echo %GN%[INFO] %WT% ÒÑÑ¡Ôñ½öCPU¡£
          set method=4
          goto :argsnext
)
        if errorlevel == 3 (
          echo %GN%[INFO] %WT% ÒÑÑ¡Ôñ½öCPU£¬µ«ÊÇÓÐÏÔ¿¨£¨4G¼°ÒÔÏÂÏÔ´æ£©¡£
          set method=3
          goto :argsnext
 )
        if errorlevel == 2 (
          echo %GN%[INFO] %WT% ÒÑÑ¡ÔñÆÕÍ¨ÏÔ¿¨£¨promptÎÞÏÞÖÆ£©¡£
          set method=2
          goto :argsnext
)
        if errorlevel == 1 (
          echo %GN%[INFO] %WT% ÒÑÑ¡ÔñÆÕÍ¨ÏÔ¿¨£¨ÎÞ²Î£©¡£
          set method=1
          goto :argsnext
)
:argsnext
(
echo [INFO]
echo method=%method%
)>installed.ini
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ÊÇ·ñÏÖÔÚÆô¶¯£¿[Y,N]
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
    echo %RD%[ERROR] %WT% ·¢Éú´íÎó¡£
    echo %RD%[ERROR] %WT% ´íÎó´úÂë£º%errcode%
  ) else (
    echo %RD%[ERROR] %WT% An error occurred.
    echo %RD%[ERROR] %WT% Error code£º%errcode%
  )
:end
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ÒÑÍ£Ö¹ÔËÐÐ¡£
    echo °´ÈÎÒâ¼üÍË³ö¡£
  ) else (
    echo %GN%[INFO] %WT% Stopped.
    echo Press any key to exit.
  )
pause>nul