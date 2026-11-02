# 103 Kubuntu (VM)
- 192.168.1.8 on vmbr1, 8 cores / 18GB. Docker host for AI + media stack.
- Running containers:
    open-webui      :3000  (AI chat / this agent)
    searxng         :8080  (privacy search)
    ebook2audiobook :7860  (ebook -> audiobook, GPU)
    metube          :8081  (alexta69/metube - YouTube frontend)
    audiobookshelf  :13378 (ghcr.io/advplyr/audiobookshelf, data home/user/audiobooks)
    watchtower      (crash-looping 2026-11-02 - not updating; fix later)
- History: metube + audiobookshelf were briefly removed 2026-11-02 (misread
  of user intent) then re-created the same day. Images were cached locally
  (alexta69/metube, ghcr.io/advplyr/audiobookshelf) so no re-pull needed.
- This VM also hosts this documentation's working tree (~/homelab) and the
  OpenWebUI agent that manages the lab.
