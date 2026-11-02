#!/usr/bin/env bash
# 工時紀錄。用法: ./log.sh start 03 | ./log.sh stop 03 | ./log.sh report
F="$(dirname "$0")/hours.csv"; [ -f "$F" ] || echo "flower,start_epoch,end_epoch" > "$F"
case "$1" in
 start) echo "$2,$(date +%s)," >> "$F";;
 stop)  python3 - "$F" "$2" <<'PY'
import csv,sys,time
f,n=sys.argv[1:3];r=list(csv.reader(open(f)))
for row in reversed(r):
    if row[0]==n and row[2]=="": row[2]=str(int(time.time()));break
csv.writer(open(f,"w")).writerows(r)
PY
  ;;
 report) python3 - "$F" <<'PY'
import csv,sys,collections
t=collections.Counter()
for r in list(csv.reader(open(sys.argv[1])))[1:]:
    if r[2]: t[r[0]]+=int(r[2])-int(r[1])
tot=0
for k in sorted(t): h=t[k]/3600;tot+=h;print(f"花 {k}: {h:.2f} h {'⚠ 超過2.07h' if h>2.07 else ''}")
print(f"合計 {tot:.2f} h / 預算 20.7 h；時薪800 → 成本 {tot*800:,.0f}，毛利約 {18000-tot*800-3*1184:,.0f}")
PY
  ;;
esac
