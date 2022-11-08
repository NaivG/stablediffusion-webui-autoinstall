@echo off
::作者秋风南霜，代码仅供学习
title webui-user
cd /d %~dp0
set ESC=
set RD=%ESC%[31m
set GN=%ESC%[32m
set YW=%ESC%[33m
set BL=%ESC%[34m
set WT=%ESC%[37m
set RN=%ESC%[0m
echo %GN%[INFO] %WT% 检测程序运行时...
python --version
if errorlevel 1 set errcode=0x0001 missing python error & goto :err
git --version
if errorlevel 1 set errcode=0x0002 missing git error & goto :err
echo %GN%[INFO] %WT% 检测完整性...
if not exist launch.py set errcode=0xA001 missing file error & goto :err
if not exist webui.py set errcode=0xA002 missing file error & goto :err
if not exist .\models\Stable-diffusion\*.ckpt set errcode=0xA003 missing model error & goto :err
if not exist installed.info goto :firstrun
if "%1"=="-update" goto :update
:start
echo %GN%[INFO] %WT% 尝试启动中...
python launch.py --skip-torch-cuda-test --lowvram --precision full --no-half
if errorlevel 1 set errcode=0x0101 running error & goto :err
goto :end

:update
echo %GN%[INFO] %WT% 尝试更新中...
git pull
if errorlevel 1 (
   echo %RD%[ERROR] %WT% 更新失败。 
   set errcode=0X0201 update error
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
echo %GN%[INFO] %WT% 尝试运行原版脚本[1/2]...
python launch.py --exit
if errorlevel 1 (
echo %GN%[INFO] %WT% 尝试运行原版脚本[2/2]...
python launch.py --skip-torch-cuda-test --exit
)
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
pip install torch torchvision -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1017 install error & goto :err
echo %GN%[INFO] %WT% 安装原版依赖...
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1018 install error & goto :err
echo %GN%[INFO] %WT% 安装xformers...
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
echo %GN%[INFO] %WT% 完成。
echo 0>installed.info
goto :start

:err
echo %RD%[ERROR] %WT% 发生错误。
echo %RD%[ERROR] %WT% 错误代码：%errcode%
:end
echo %GN%[INFO] %WT% 已停止运行。
echo 按任意键退出。
pause>nul
