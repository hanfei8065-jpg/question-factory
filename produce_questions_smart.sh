#!/bin/bash
 TOTAL=200
API_URL="https://wsoilhwdxncnumzttbaz.supabase.co/functions/v1/question-factory-v542?lang=en"
API_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indzb2lsaHdkeG5jbnVtenR0YmF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyMDk1NDksImV4cCI6MjA3Nzc4NTU0OX0.XXgTbuqXA0McFo17xakcRvGuX0ilkJfYIVpQ4JTxF_k"
LOGFILE="produce_questions.log"

for ((i=1; i<=TOTAL; i++))
do
  echo "[$(date)] Batch $i/$TOTAL" | tee -a $LOGFILE
  RETRY=0
  SUCCESS=0
  while [ $RETRY -lt 3 ]; do
    RESULT=$(curl -s -X POST "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json")
    echo "[$(date)] Result: $RESULT" | tee -a $LOGFILE
    if [[ $RESULT == *'"success":true'* ]]; then
      SUCCESS=1
      break
    else
      echo -e "\033[31m[$(date)] Error: Batch $i failed, retrying ($((RETRY+1))/3)...\033[0m" | tee -a $LOGFILE
      sleep 5
      ((RETRY++))
    fi
  done
  if [ $SUCCESS -eq 0 ]; then
    echo -e "\033[41m[$(date)] ALERT: Batch $i failed after 3 retries!\033[0m" | tee -a $LOGFILE
  fi
  sleep 10
done

echo "[$(date)] All batches finished!" | tee -a $LOGFILE