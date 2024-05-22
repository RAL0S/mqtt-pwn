#!/usr/bin/env bash

set -e

mkdir workspace
wget https://github.com/indygreg/python-build-standalone/releases/download/20220802/cpython-3.9.13+20220802-x86_64-unknown-linux-gnu-install_only.tar.gz
tar xf cpython-3.9.13+20220802-x86_64-unknown-linux-gnu-install_only.tar.gz -C workspace

cd workspace

cat <<EOF >pyproject.toml
[build-system]
requires = ["setuptools"]
build-backend = "setuptools.build_meta"
EOF

cat <<EOF >setup.cfg
[metadata]
name = mqtt-pwn
version = 40368e5

[options]
scripts =
    mqtt-pwn/run.py

package_dir =
    = mqtt-pwn

packages = find:

install_requires =
    aiohttp==3.2.1
    alabaster==0.7.10
    async-timeout==3.0.0
    attrs==18.1.0
    Babel==2.5.3
    blessings @ git+https://github.com/erikrose/blessings
    certifi==2018.4.16
    chardet==3.0.4
    Click==7.0
    click-plugins==1.0.4
    cmd2==2.4.2
    colorama==0.4.0
    docutils==0.14
    future==0.16.0
    idna==2.6
    idna-ssl==1.1.0
    imagesize==1.0.0
    Jinja2==2.10
    MarkupSafe==1.1.0
    multidict==4.3.1
    packaging==19.0
    paho-mqtt==1.3.1
    peewee==3.3.2
    prettytable==0.7.2
    Pygments==2.2.0
    PyMySQL==0.8.1
    pyparsing==2.2.0
    pyperclip==1.6.0
    pytz==2018.4
    requests==2.20.0
    shodan==1.10.4
    six==1.11.0
    snowballstemmer==1.2.1
    Sphinx==1.7.4
    sphinxcontrib-websupport==1.0.1
    urllib3==1.24.2
    wcwidth==0.1.7
    XlsxWriter==1.1.2
    yarl==1.2.4

[options.packages.find]
where = mqtt-pwn

[options.package_data]
resources =
    wordlists/*.txt
    *.json
EOF

git clone https://github.com/akamai-threat-research/mqtt-pwn
cd mqtt-pwn
git checkout 40368e531660339fca1562a6c609c35f7ae4f989
touch resources/__init__.py

#sed -i '/^idna-ssl/c idna-ssl==1.1.0' requirements.txt
#sed -i '/^MarkupSafe/c MarkupSafe==1.1.0' requirements.txt
#sed -i '/^blessings/c blessings==1.7' requirements.txt
#sed -i '/^cmd2/c cmd2==2.4.2' requirements.txt
#sed -i '/^packaging/c packaging==19.0' requirements.txt
#sed -i '/^psycopg2-binary/d' requirements.txt
sed -i 's/is_test_env =/is_test_env = True#/' mqtt_pwn/database.py
sed -i '/^BASE_PATH =/c BASE_PATH = os.path.dirname(__file__) + "/"' mqtt_pwn/config.py
sed -i '1i #!/usr/bin/env python3' run.py
cd ..

./python/bin/pip3 install build

echo "Building Wheel==="

./python/bin/python3 -m build --wheel
mv dist/mqtt_pwn-40368e5-py3-none-any.whl .

echo "Building AppImage==="

mkdir appimage-recipe
cd appimage-recipe
wget https://raw.githubusercontent.com/akamai-threat-research/mqtt-pwn/master/docs/_static/images/another-logo-trans-bg-small.png -O mqtt-pwn.png

cat <<EOF >mqtt-pwn.desktop
[Desktop Entry]
Type=Application
Name=mqtt-pwn
Exec=mqtt-pwn
Comment=MQTT-PWN intends to be a one-stop-shop for IoT Broker penetration-testing and security assessment operations
Icon=mqtt-pwn
Categories=System;
Terminal=true
EOF

cat <<EOF >requirements.txt
$(pwd)/../mqtt_pwn-40368e5-py3-none-any.whl
EOF

cat <<EOF >entrypoint.sh
{{ python-executable }} -I "\${APPDIR}/opt/python{{ python-version }}/bin/run.py" "\$@"
EOF

cat <<EOF >mqtt-pwn.appdata.xml
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop-application">
    <id>mqtt-pwn</id>
    <metadata_license>GPL-3.0</metadata_license>
    <project_license>Python-2.0</project_license>
    <name>MQTT-PWN</name>
    <summary>MQTT-PWN on Python {{ python-fullversion }}</summary>
    <description>
        <p>  Python {{ python-fullversion }} + MQTT-PWN bundled in an AppImage.
        </p>
    </description>
    <launchable type="desktop-id">mqtt-pwn.desktop</launchable>
    <url type="homepage">https://github.com/akamai-threat-research/mqtt-pwn</url>
    <provides>
        <binary>python{{ python-version }}</binary>
    </provides>
</component>
EOF

cd ..
./python/bin/pip3 install python-appimage
./python/bin/python-appimage build app -p 3.9 appimage-recipe
mv mqtt-pwn-x86_64.AppImage ..
