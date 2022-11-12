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
if errorlevel 1 set errcode=0x0001 missing python error & goto :err
git --version
if errorlevel 1 set errcode=0x0002 missing git error & goto :err
echo %GN%[INFO] %WT% ���½ű���...
git pull
if errorlevel 1 (
echo %YW%[WARN] %WT% ����ʧ�ܡ�
echo         ��Ҫ���뱣����Ľű�Ϊ���¡�
echo               ���°�ű�ȫ�������ȶ����ԣ�����ӵ���¹��ܡ�
) else (
echo %GN%[INFO] %WT% ���³ɹ���
)
if not exist installed.info goto :firstrun
cd stable-diffusion-webui
if "%1"=="-update" goto :update
:start
echo %GN%[INFO] %WT% ���������...
if not exist launch.py set errcode=0xA001 missing file error & goto :err
if not exist webui.py set errcode=0xA002 missing file error & goto :err
if not exist .\models\Stable-diffusion\*.ckpt set errcode=0xA003 missing model error & goto :err
echo %GN%[INFO] %WT% ����������...
python launch.py --skip-torch-cuda-test --lowvram --precision full --no-half
if errorlevel 1 set errcode=0x0101 running error & goto :err
goto :end

:update
echo %GN%[INFO] %WT% ���Ը�����...
git pull
if errorlevel 1 (
   echo %RD%[ERROR] %WT% ����ʧ�ܡ� 
   set errcode=0X0201 update error
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
pip install torch torchvision -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1017 install error & goto :err
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
echo %GN%[INFO] %WT% ��ɡ�
cd ..
echo 0>installed.info
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
echo %GN%[INFO] %WT% �Ƿ�������[Y,N]
    choice -n -c yn >nul
        if errorlevel == 2 (
		echo ��������˳���
        pause>nul
		goto :scriptend
		)
        if errorlevel == 1 goto :start

:scriptend