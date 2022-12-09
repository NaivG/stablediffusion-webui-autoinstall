@echo off
::×÷ÕßÇï·çÄÏËª£¬´úÂë½ö¹©Ñ§Ï°
title webui-user
cd /d %~dp0
set ESC=
set RD=%ESC%[31m
set GN=%ESC%[32m
set YW=%ESC%[33m
set BL=%ESC%[34m
set WT=%ESC%[37m
set RN=%ESC%[0m
echo %GN%[INFO] %WT% ¼ì²â³ÌÐòÔËÐÐÊ±...
python --version
if errorlevel 1 set errcode=0x0001 missing python error & goto :err
git --version
if errorlevel 1 set errcode=0x0002 missing git error & goto :err
echo %GN%[INFO] %WT% À­È¡¹«¸æ...
type notice.txt
echo.
if not exist notice.txt echo %YW%[WARN] %WT% À­È¡Ê§°Ü¡£
ping -n 2 127.1>nul
echo %GN%[INFO] %WT% ¸üÐÂ½Å±¾ÖÐ...
git pull
if errorlevel 1 (
echo %YW%[WARN] %WT% ¸üÐÂÊ§°Ü¡£
echo         ÖØÒª£ºÇë±£³ÖÄãµÄ½Å±¾Îª×îÐÂ¡£
echo               ×îÐÂ°æ½Å±¾È«²¿¾­¹ýÎÈ¶¨²âÊÔ£¬²¢ÇÒÓµÓÐÐÂ¹¦ÄÜ¡£
ping -n 3 127.1>nul
) else (
echo %GN%[INFO] %WT% ¸üÐÂ³É¹¦¡£
)
if not exist installed.info goto :firstrun
cd stable-diffusion-webui
if "%1"=="-update" goto :update
:start
echo %GN%[INFO] %WT% ¼ì²âÍêÕûÐÔ...
if not exist launch.py set errcode=0xA001 missing file error & goto :err
if not exist webui.py set errcode=0xA002 missing file error & goto :err
if not exist .\models\Stable-diffusion\*.ckpt set errcode=0xA003 missing model error & goto :err
echo %GN%[INFO] %WT% ³¢ÊÔÆô¶¯ÖÐ...
python launch.py --index_url "https://pypi.tuna.tsinghua.edu.cn/simple" --skip-torch-cuda-test --lowvram --precision full --no-half
if errorlevel 1 set errcode=0x0101 running error & goto :err
goto :end

:update
echo %GN%[INFO] %WT% ³¢ÊÔ¸üÐÂÖÐ...
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
echo %GN%[INFO] %WT% ÇëÑ¡ÔñÏÔ¿¨°æ±¾£¨°æ±¾²»»¥Í¨£©
echo       CPU»òNVIDIAÑ¡Ôña£¬AMDÑ¡Ôñb
    choice -n -c ab >nul
        if errorlevel == 2 (
          echo %GN%[INFO] %WT% ÒÑÑ¡ÔñAMD°æ±¾¡£
          set TORCHVER=AMD
        )
        if errorlevel == 1 (
          echo %GN%[INFO] %WT% ÒÑÑ¡ÔñCPU»òNVIDIA°æ±¾¡£
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
if not exist .\models\*.ckpt echo %YW%[WARN] %WT% ÕÒ²»µ½Ä£ÐÍÎÄ¼þ£¬ÇëÉÔºó·ÅÖÃ¡£
if exist .\models\*.ckpt (
   echo %GN%[INFO] %WT% ÕýÔÚ¸´ÖÆÄ£ÐÍÎÄ¼þ...
   copy .\models\*.* .\stable-diffusion-webui\models\Stable-diffusion\
)
copy %0 .\stable-diffusion-webui\
cd .\stable-diffusion-webui\
echo %GN%[INFO] %WT% ³¢ÊÔÔËÐÐÔ­°æ½Å±¾[1/2]...
python launch.py --exit
if errorlevel 1 (
echo %GN%[INFO] %WT% ³¢ÊÔÔËÐÐÔ­°æ½Å±¾[2/2]...
python launch.py --skip-torch-cuda-test --exit
)
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
echo %GN%[INFO] %WT% °²×°pytorch...
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
echo %GN%[INFO] %WT% °²×°Ô­°æÒÀÀµ...
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1018 install error & goto :err
echo %GN%[INFO] %WT% °²×°xformers...
pip install xformers -i https://pypi.tuna.tsinghua.edu.cn/simple
echo %GN%[INFO] %WT% pulling git...
md repositories
cd repositories
echo %GN%[INFO] %WT% pulling DeepDanbooru...
git clone https://ghproxy.com/https://github.com/KichangKim/DeepDanbooru.git
cd DeepDanbooru
python setup.py build
python setup.py install
cd ..
echo %GN%[INFO] %WT% pulling stable-diffusion[1/2]...
git clone https://github.com/CompVis/stable-diffusion.git
if errorlevel 1 (
echo %GN%[INFO] %WT% pulling stable-diffusion[2/2]...
git clone https://ghproxy.com/https://github.com/CompVis/stable-diffusion.git
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
echo %GN%[INFO] %WT% Íê³É¡£
cd ..
echo [INFO]>installed.info
echo TORCHVER=%TORCHVER%>>installed.info
echo %GN%[INFO] %WT% ÊÇ·ñÏÖÔÚÆô¶¯£¿[Y,N]
    choice -n -c yn >nul
        if errorlevel == 2 goto :end
        if errorlevel == 1 (
		cd stable-diffusion-webui
		goto :start
		)
goto :end

:err
echo %RD%[ERROR] %WT% ·¢Éú´íÎó¡£
echo %RD%[ERROR] %WT% ´íÎó´úÂë£º%errcode%
:end
echo %GN%[INFO] %WT% ÒÑÍ£Ö¹ÔËÐÐ¡£
echo °´ÈÎÒâ¼üÍË³ö¡£
        pause>nul