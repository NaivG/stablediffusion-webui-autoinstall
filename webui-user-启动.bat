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
echo %GN%[INFO] %WT% ¼ì²âÍêÕûÐÔ...
if not exist launch.py set errcode=0xA001 missing file error & goto :err
if not exist webui.py set errcode=0xA002 missing file error & goto :err
if not exist .\models\Stable-diffusion\*.ckpt set errcode=0xA003 missing model error & goto :err
if not exist installed.info goto :firstrun
:start
echo %GN%[INFO] %WT% ³¢ÊÔÆô¶¯ÖÐ...
python webui.py --lowvram --precision full --no-half
goto :end
:err
echo %RD%[ERROR] %WT% ·¢Éú´íÎó¡£
echo %RD%[ERROR] %WT% ´íÎó´úÂë£º%errcode%
:end
echo %GN%[INFO] %WT% ÒÑÍ£Ö¹ÔËÐÐ¡£
echo °´ÈÎÒâ¼üÍË³ö¡£
pause>nul
exit

:firstrun
echo %GN%[INFO] %WT% ¼ì²â°²×°Ìõ¼þ...
pip --version
if errorlevel 1 set errcode=0x1001 missing pip error & goto :err
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
pip install torch torchvision -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1017 install error & goto :err
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
echo 0>installed.info
goto :start
