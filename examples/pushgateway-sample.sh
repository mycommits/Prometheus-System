num_files=$(find /backup -mtime +7 -delete  | wc -l)

cat << EOF | curl --data-binary @- http://prometheus:9091/metrics/job/debug_cleanup/instance/10.0.1.102
  # TYPE job_executed_successful gauge
  job_executed_successful 1
  # TYPE job_num_files_deleted gauge
  job_num_files_deleted $num_files
EOF