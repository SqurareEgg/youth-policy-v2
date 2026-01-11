#!/bin/bash
echo "GitHub Username을 입력하세요:"
read username
git remote add origin "https://github.com/$username/youth-policy-v2.git"
git branch -M main
git push -u origin main
echo "푸시 완료!"
