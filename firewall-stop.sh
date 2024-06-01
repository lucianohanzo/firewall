#!/bin/bash

#Padrão
# Tabela, Chain, Placa, IP, Protocolo, Porta, Acão.

# Limpa todas as cadeias da tabela filter
iptables -t filter -F

# Definindo a politica padrão.
iptables -t filter -P INPUT ACCEPT
iptables -t filter -P FORWARD ACCEPT
iptables -t filter -P OUTPUT ACCEPT

# Deleta as cadeias criadas
iptables -t filter -X

