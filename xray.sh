#/bin/bash
apt update && apt upgrade -y -f
apt install curl unzip nginx-full net-tools -y
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
clear
_banner(){
  printf "\033[0;31m=================================\n"
  printf "\033[0;31m=     Created By LiL ONE     =\n"
  printf "\033[0;31m=================================\n"
}
_start(){
  _banner
  read -p "$(printf '\033[1;36mCert Url: \033[1;34m')" CertURL
  if ! [[ $CertURL == https://raw.githubusercontent.com/* ]];then
      printf "\033[0;31mwrong input\n \033[1;37m[\033[1;32m*\033[1;37m] \033[1;33mthe input must start with '\033[1;32m https://raw.githubusercontent.com\033[1;33m'\n"
      sleep 2
      clear
      _start
  else
    read -p "$(printf '\033[1;36mCert Key: \033[1;34m')" KeyURL
    if ! [[ $KeyURL == https://raw.githubusercontent.com/* ]];then
      printf "\033[0;31mwrong input\n \033[1;37m[\033[1;32m*\033[1;37m] \033[1;33mthe input must start with '\033[1;32mhttps://raw.githubusercontent.com/\033[1;33m'\n"
      sleep 2
      clear
      _start
    else
      read -p "$(printf '\033[1;36mDomain: \033[1;34m')" MyDomain
      printf "\033[0m"
      if ! [[ $MyDomain =~ ^[0-9a-zA-Z\.\-]+$ ]];then
        printf "\033[0;31mwrong input\n \033[1;37m[\033[1;32m*\033[1;37m] \033[1;33mthe input must not have special character exept \033[1;32m- \033[1;33mand \033[1;32m.\033[0m \n"
        sleep 2
        clear
        _start
      fi
    fi
  fi
}

_start


v2raydir='/usr/local/etc/v2ray' && curl -kL "$CertURL" -o $v2raydir/cert.pem && curl -kL "$KeyURL" -o $v2raydir/key.pem && curl -kL "https://support.cloudflare.com/hc/article_attachments/360037898732/origin_ca_ecc_root.pem" -o $v2raydir/root_ecc.pem
v2raydir='/usr/local/etc/v2ray' && printf "%b\n" "$(cat $v2raydir/cert.pem)\n$(cat $v2raydir/cert.pem)\n$(cat $v2raydir/root_ecc.pem)" > $v2raydir/fullchain.pem

MyUUID=$(curl -skL -w "\n" https://www.uuidgenerator.net/api/version4)
v2rayconf='/usr/local/etc/v2ray/config.json' && nginxv2conf='/etc/nginx/conf.d/v2ray.conf' && gistlink='https://gist.githubusercontent.com/Bonveio/59e8b9561e20e8b612f65a3d47a97d13/raw' && curl -kL "$gistlink/config.json" -o $v2rayconf && curl -kL "$gistlink/v2ray.conf" -o $nginxv2conf && sed -i "s|SERVER_DOMAIN|$MyDomain|g;s|GENERATED_UUID_CODE|$MyUUID|g" $v2rayconf && sed -i "s|DOMAIN_HERE|$MyDomain|g" $nginxv2conf

rm -rf /etc/nginx/{default.d,conf.d/default.conf,sites-*}

if [[ $(netstat -tlnp | grep -E ':80' | awk '{print $4}' | sed -e 's/.*://') = 80 ]]; then
  printf "\033[1;33mPORT 80 Running... killing it\033[0m"
  kill $(lsof -t -i :80)
fi
if [[ $(netstat -tlnp | grep -E ':443' | awk '{print $4}' | sed -e 's/.*://') = 443 ]]; then
  printf "\033[1;33mPORT 443 Running... killing it\033[0m"
  kill $(lsof -t -i :443)
fi
if [[ $(netstat -tlnp | grep -E ':10035' | awk '{print $4}' | sed -e 's/.*://') = 10035 ]]; then
  printf "\033[1;33mPORT 10035 Running... killing it\033[0m"
  kill $(lsof -t -i :10035)
fi

systemctl start xray 2>/dev/null && systemctl restart nginx
sleep 3
netstat -tlnp | grep -E '(:10035|:443|:80)'

printf "\033[1;33mYour UUID Code:\033[1;36m $MyUUID\033[0m\n"

printf "[\033[1;32mDONE\033[0m]\n"



