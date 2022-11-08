# stablediffusion-webui-cpuinstall
install stablediffusion-webui and run without gpu

半自动化安装stablediffusion-webui（核显版）

---
# 注意
模型未安装前放在\models文件夹内
国内未换源的需要把launch.py的第十五行

* index_url = os.environ.get('INDEX_URL', "")

改成如下以换源

* index_url = "https://pypi.tuna.tsinghua.edu.cn/simple"
