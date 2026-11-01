# 102 Windows11 (VM)
- 192.168.1.12 on vmbr1, 8 cores / 12GB. Currently STOPPED.
- EXCLUDED from all vzdump jobs on purpose (Windows guest backups are slow
  and the data is not considered irreplaceable; personal data is synced
  elsewhere). If that assumption changes, add it to a job in jobs.cfg.
