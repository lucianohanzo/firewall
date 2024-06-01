#!/bin/bash

#Padrão
# Tabela, Chain, Placa, IP, Protocolo, Porta, Acão.

# Limpa todas as cadeias da tabela filter
iptables -F

# Definindo a politica padrão.
iptables -t filter -P INPUT DROP
iptables -t filter -P FORWARD DROP
iptables -t filter -P OUTPUT DROP


# Libera loopback no Firewall.
iptables -t filter -A INPUT  -i lo -j ACCEPT
iptables -t filter -A OUTPUT -o lo -j ACCEPT


#========> SSH <========#
# Libera o SSH no Firewall para computadores na mesma rede.
iptables -t filter -A INPUT  -s 192.168.72.0/24 -p tcp --dport 22 -j ACCEPT
iptables -t filter -A OUTPUT -d 192.168.72.0/24 -p tcp --sport 22 -j ACCEPT
# Acesso ao servidor via SSH
iptables -t filter -A OUTPUT -d 192.168.72.250 -p tcp --dport 8472 -j ACCEPT
iptables -t filter -A INPUT  -s 192.168.72.250 -p tcp --sport 8472 -j ACCEPT


#========> NTP <========#
iptables -A OUTPUT -p udp --dport 123 -j ACCEPT
iptables -A INPUT  -p udp --sport 123 -j ACCEPT


#========> DNS <========#
iptables -A OUTPUT -o enp5s0 -p udp --dport 53 --sport 1024:65535 -j ACCEPT
iptables -A INPUT  -i enp5s0 -p udp --sport 53 --dport 1024:65535 -j ACCEPT


#========> Torrents <========#
iptables -t filter -N TORRENTS

iptables -A OUTPUT -p udp --sport 55000 -j TORRENTS
iptables -A INPUT  -p udp --dport 55000 -j TORRENTS

iptables -A TORRENTS -p udp --sport 55000 -j ACCEPT
iptables -A TORRENTS -p udp --dport 55000 -j ACCEPT

# Track de torrent BJ-SHARE
iptables -A OUTPUT -p tcp --dport 2053 -j TORRENTS
iptables -A INPUT  -p tcp --sport 2053 -j TORRENTS

iptables -A TORRENTS -p tcp --dport 2053 -j ACCEPT
iptables -A TORRENTS -p tcp --sport 2053 -j ACCEPT


#========> WEB <========#
iptables -t filter -N INTERNET

iptables -t filter -A OUTPUT -p tcp -m multiport --dports 80,443,8080 -j INTERNET
iptables -t filter -A INPUT  -p tcp -m multiport --sports 80,443,8080 -j INTERNET

iptables -t filter -A INTERNET -p tcp -m multiport --dports 80,443,8080 -j ACCEPT
iptables -t filter -A INTERNET -p tcp -m multiport --sports 80,443,8080 -j ACCEPT


#========> PING <========#
iptables -A OUTPUT -p icmp -j ACCEPT

iptables -A INPUT  \
    -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT

iptables -A INPUT  \
    -p icmp --icmp-type echo-reply   -m limit --limit 1/s -j ACCEPT

#iptables -A OUTPUT -p icmp -j DROP


#========> Servidor SAMBA <========#
# Acesso ao servidor de arquivos.
iptables -A OUTPUT -d 192.168.72.255 -p udp --dport 137 -j ACCEPT
#iptables -A INPUT  -s 192.168.72.255 -p udp --sport 137 -j ACCEPT

iptables -A OUTPUT -d 192.168.72.250 -p udp --dport 138 -j ACCEPT
iptables -A INPUT  -s 192.168.72.250 -p udp --sport 137:138 -j ACCEPT

iptables -A OUTPUT -d 192.168.72.250 -p tcp --dport 139 -j ACCEPT
iptables -A INPUT  -s 192.168.72.250 -p tcp --sport 139 -j ACCEPT

iptables -A OUTPUT -d 192.168.72.250 -p tcp --dport 445 -j ACCEPT
iptables -A INPUT  -s 192.168.72.250 -p tcp --sport 445 -j ACCEPT


#========> Overwatch - PC <========#
iptables -t filter -N OVERWATCH

iptables -A OUTPUT -p tcp -m multiport --dports 1119,3724 -j OVERWATCH
iptables -A INPUT  -p tcp -m multiport --sports 1119,3724 -j OVERWATCH
iptables -A OUTPUT -p udp -m multiport --dports 26500:26800 -j OVERWATCH
iptables -A INPUT  -p udp -m multiport --sports 26500:26800 -j OVERWATCH

iptables -A OVERWATCH -p tcp -m multiport --dports 1119,3724 -j ACCEPT
iptables -A OVERWATCH -p tcp -m multiport --sports 1119,3724 -j ACCEPT
iptables -A OVERWATCH -p udp -m multiport --dports 26500:26800 -j ACCEPT
iptables -A OVERWATCH -p udp -m multiport --sports 26500:26800 -j ACCEPT


#========> ANYDESK <========#
iptables -A OUTPUT -p tcp --dport 6586 -j ACCEPT
iptables -A INPUT  -p tcp --sport 6586 -j ACCEPT
# Descoberta na rede
iptables -A OUTPUT -p tcp --dport 50001:50003 -j ACCEPT
iptables -A INPUT  -p tcp --sport 50001:50003 -j ACCEPT


#========> MIKROTIK <========#

iptables -t filter -N MIKROTIK

iptables -A OUTPUT -p tcp -m multiport --dports 3333,6633,9933 -j MIKROTIK
iptables -A INPUT  -p tcp -m multiport --sports 3333,6633,9933 -j MIKROTIK

iptables -A MIKROTIK -p tcp -m multiport --dports 3333,6633,9933 -j ACCEPT
iptables -A MIKROTIK -p tcp -m multiport --sports 3333,6633,9933 -j ACCEPT


#========> E-mail <========#
iptables -t filter -N E-MAIL

iptables -A OUTPUT -p tcp -m multiport --dports 465,587,993,995 -j E-MAIL
iptables -A INPUT  -p tcp -m multiport --sports 465,587,993,995 -j E-MAIL

iptables -A E-MAIL -p tcp -m multiport --dports 465,587,993,995 -j ACCEPT
iptables -A E-MAIL -p tcp -m multiport --sports 465,587,993,995 -j ACCEPT

echo "Firewall ativado com sucesso!"


#FIM
