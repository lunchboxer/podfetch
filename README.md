# Podfetch

A very simple shell script to fetch podcasts. It will only download the lastest episode of each podcast. That may not always be the behavior you want, but it is for me. It runs in three parts:

1. Download all podcast reeds from ~/.config/podfetch/feed-url-list.txt
2. Check the latest episode of each podcast against ~/.cache/podfetch/downloaded.log
3. Download episodes that are in ~/.cache/podfetch/pending.list
4. Run all user scripts in ~/.config/podfetch/scripts

The user scripts can be used to rename files, reorganize them, or automatically tidy the podcast directory to only keep the very latest episode of a podcast. This is useful for hourly news.

It doesn't play podcasts or do anything with the episoodes. You can sync the folder by yourself to your phone or an audioplayer and enjoy in whatever way you like. I have found that many audio players for android do not keep good track of last played track and position which can be frustrating for podcasts or audiobooks. Podcast apps usually do a good job with this, but I found the inclusion of podcast directory search and podcast fetching features to be offensive to my minimalist sensibilities. Perhaps you feel the same way. Good luck if you can find a clean and easy to use minimalist, FOSS, podcast (and maybe audiobook) playing app. Let me know if you strike gold.  
