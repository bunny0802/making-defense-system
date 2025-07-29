#!/bin/bash

# --------- SETUP ---------
read -p "Enter the target domain (eg: example.com): " DOMAIN
OUTPUT_FILE="recon_scan_${DOMAIN}.txt"

echo "Starting Recon on $DOMAIN"
echo "Output will be saved to $OUTPUT_FILE"
echo -e "\n==== Recon on $DOMAIN ====\n" > "$OUTPUT_FILE"

# --------- WHOIS ---------
echo "[+] WHOIS Info..." | tee -a "$OUTPUT_FILE"
whois $DOMAIN 2>/dev/null | tee -a "$OUTPUT_FILE"

# --------- DNS INFO ---------
echo -e "\n[+] DNS Records..." | tee -a "$OUTPUT_FILE"
dig $DOMAIN any +short | tee -a "$OUTPUT_FILE"

# --------- SUBDOMAIN ENUM (passive) ---------
echo -e "\n[+] Subdomain Enumeration (assetfinder)..." | tee -a "$OUTPUT_FILE"
assetfinder --subs-only $DOMAIN 2>/dev/null | tee -a "$OUTPUT_FILE"

# --------- PORT SCAN ---------
echo -e "\n[+] Port Scanning (nmap - top 1000)..." | tee -a "$OUTPUT_FILE"
nmap -T4 -sS -Pn -vv --top-ports 1000 $DOMAIN | tee -a "$OUTPUT_FILE"

# --------- SERVICE ENUM ---------
echo -e "\n[+] Service Version Detection (nmap -sV)..." | tee -a "$OUTPUT_FILE"
nmap -sV -Pn $DOMAIN | tee -a "$OUTPUT_FILE"

# --------- WEB TECHNOLOGY DETECTION ---------
echo -e "\n[+] Web Tech Stack (whatweb)..." | tee -a "$OUTPUT_FILE"
whatweb $DOMAIN | tee -a "$OUTPUT_FILE"

# --------- DIRECTORY BRUTEFORCE ---------
echo -e "\n[+] Directory Brute-forcing (gobuster)..." | tee -a "$OUTPUT_FILE"
gobuster dir -u http://$DOMAIN -w /usr/share/wordlists/dirb/common.txt -q -t 30 2>/dev/null | tee -a "$OUTPUT_FILE"

# --------- BANNER GRABBING ---------
echo -e "\n[+] HTTP Banner Grab (curl)..." | tee -a "$OUTPUT_FILE"
curl -I http://$DOMAIN 2>/dev/null | tee -a "$OUTPUT_FILE"

# --------- LIGHT VULN SCAN (optional) ---------
echo -e "\n[+] Web Vulnerability Scan (nikto)..." | tee -a "$OUTPUT_FILE"
nikto -h http://$DOMAIN | tee -a "$OUTPUT_FILE"

echo -e "\n[✓] Recon complete. Results saved to $OUTPUT_FILE"
