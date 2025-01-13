# ��������ʹ�����µ� Debian ϵͳ
FROM debian:latest AS base
# ���û���������ȷ��ʹ������ UTF-8 ����
ENV LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8
# ����������б���װ��Ҫ�Ĺ��ߺͿ�
RUN apt update \
    && DEBIAN_FRONTEND=noninteractive \
    && apt install -y wget curl unzip locales locales-all \
    && locale-gen zh_CN.UTF-8 \
    && update-locale LANG=zh_CN.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# ���滷�����ڻ��������ϰ�װ���������
FROM base AS desktop
# ����������б���װ���滷����ع���
RUN apt update \
    && DEBIAN_FRONTEND=noninteractive \
    # ��װ�ļ��������������������ڹ�������
    && apt install -y pcmanfm tint2 openbox xauth xinit \
    && rm -rf /var/lib/apt/lists/*

# TigerVNC �������������滷���ϰ�װ TigerVNC
FROM desktop AS tigervnc
# ���ز���ѹ TigerVNC ������
RUN wget -qO- https://sourceforge.net/projects/tigervnc/files/stable/1.14.1/tigervnc-1.14.1.x86_64.tar.gz | tar xz --strip 1 -C /

# noVNC ������ TigerVNC �����ϰ�װ noVNC ����
FROM tigervnc AS novnc
# ���� noVNC ��װĿ¼
ENV NO_VNC_HOME=/usr/share/usr/local/share/noVNCdim
# ����������б���װ Python ��
RUN apt update \
    && DEBIAN_FRONTEND=noninteractive apt install -y python3-numpy \
    # ���� noVNC �� websockify ��Ŀ¼�ṹ
    && mkdir -p "${NO_VNC_HOME}/utils/websockify" \
    # ���ز���ѹ noVNC �� websockify
    && wget -qO- "https://github.com/novnc/noVNC/archive/v1.5.0.tar.gz" | tar xz --strip 1 -C "${NO_VNC_HOME}" \
    && wget -qO- "https://github.com/novnc/websockify/archive/v0.12.0.tar.gz" | tar xz --strip 1 -C "${NO_VNC_HOME}/utils/websockify" \
    # ʹ noVNC �����ִ��
    && chmod +x -v "${NO_VNC_HOME}/utils/novnc_proxy" \
    # �޸� noVNC �� UI.js ��֧���Զ�������С
    && sed -i '1s/^/if(localStorage.getItem("resize") == null){localStorage.setItem("resize","remote");}\n/' "${NO_VNC_HOME}/app/ui.js" \
    && rm -rf /var/lib/apt/lists/*

# 115 ��������� noVNC �����ϰ�װ 115 �����
FROM novnc AS oneonefive
# ���û�������
ENV \
    XDG_CONFIG_HOME=/tmp \
    XDG_CACHE_HOME=/tmp \
    HOME=/opt \
    DISPLAY=:115 \
    LD_LIBRARY_PATH=/usr/local/115Browser:\$LD_LIBRARY_PATH
# ����������б���װ��Ҫ�Ŀ�
RUN apt update \
    && DEBIAN_FRONTEND=noninteractive \
    && apt install -y libnss3 libasound2 libgbm1 \
    # ���ز���װ jq ����
    && wget -q --no-check-certificate -c https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64 \
    && chmod +x jq-linux-amd64 \
    && mv jq-linux-amd64 /usr/bin/jq \
    # ��ȡ 115 ����������°汾��
    && export VERSION=`curl -s https://appversion.115.com/1/web/1.0/api/getMultiVer | jq '.data["Linux-115chrome"].version_code'  | tr -d '"'` \
    # ���ز���װ 115 �����
    && wget -q --no-check-certificate -c "https://down.115.com/client/115pc/lin/115br_v${VERSION}.deb" \
    && apt install "./115br_v${VERSION}.deb"  \
    && rm "115br_v${VERSION}.deb" \
    # ���ز���ѹ 115Cookie ��չ
    && wget -q --no-check-certificate -c https://github.com/kin-w/115Cookie/archive/refs/heads/master.zip \
    && unzip -j master.zip -d /usr/local/115Cookie/ \
    && rm master.zip \
    # ������Ҫ��Ŀ¼������Ȩ��
    && mkdir -p /opt/Desktop \
    && mkdir -p /opt/Downloads \
    && chmod 777 -R /opt/Downloads \
    && cp /usr/share/applications/115Browser.desktop /opt/Desktop \
    && cp /usr/share/applications/pcmanfm.desktop /opt/Desktop \
    && chmod 777 -R /opt \
    && mkdir -p /etc/115 \
    && chmod 777 -R /etc/115 \
    # ���� 115 ����������ű�
    && echo "cd /usr/local/115Browser" > /usr/local/115Browser/115.sh \
    && echo "/usr/local/115Browser/115Browser \
    --test-type \
    --disable-backgrounding-occluded-windows \
    --user-data-dir=/etc/115 \
    --disable-cache \
    --load-extension=/usr/local/115Cookie \
    --disable-wav-audio \
    --disable-logging \
    --disable-notifications \
    --no-default-browser-check \
    --disable-background-networking \
    --enable-features=ParallelDownloading \
    --start-maximized \
    --no-sandbox \
    --disable-vulkan \
    --disable-gpu \
    --ignore-certificate-errors \
    --disable-bundled-plugins \
    --disable-dev-shm-usage \
    --reduce-user-agent-sniffing \
    --no-first-run \
    --disable-breakpad \
    --disable-gpu-process-crash-limit \
    --enable-low-res-tiling \
    --disable-heap-profiling \
    --disable-features=IsolateOrigins,site-per-process \
    --disable-smooth-scrolling \
    --lang=zh-CN \
    --disable-software-rasterizer \
    >/tmp/115Browser.log 2>&1 &" >> /usr/local/115Browser/115.sh \
    && rm -rf /var/lib/apt/lists/*

# ���վ��񣺱�¶ 1150 �˿ڲ����������ű�
FROM oneonefive
EXPOSE 1150
COPY run.sh /opt/run.sh
CMD ["bash","/opt/run.sh"]
