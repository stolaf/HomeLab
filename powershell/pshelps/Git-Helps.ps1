break 

git config --global user.name "Olaf Stagge"
git config --global user.email extern.olaf.stagge@vwfs.com

#region gitignore
# Compiled source #
*.com
*.class
*.dll
*.exe
*.o
*.so

# Packages #it's better to unpack these files and commit the raw source # git has its own built in compression methods
*.7z
*.dmg
*.gz
*.iso
*.jar
*.rar
*.tar
*.zip

# Logs and databases #
*.log
*.sql
*.sqlite

# OS generated files #
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
#endregion gitignore
#region gitconfig
[user]
	name = Olaf Stagge
	email = extern.olaf.stagge@vwfs.com

[http]
[http "https://dev.azure.com"]
	proxy = http://10.41.77.154:8080
	
[http "https://github.com"]
	proxy = http://10.41.77.154:8080
#endregion gitconfig

git init <projektname>
git clone https://github.com/bfrankMS/IaaS-ACDMY.git

git clone http://tfs.t-fs01.vwfs-ad:8080/tfs/VWFSAG/FS.AzureStackgit commit -m "Initial"/_git/CreateAdminVM
git add .     # alle neuen Files hinzufügen inkl. Unterordner
git commit -m "Initial"   # -m = Message
git push

git branch master
git checkout -b "master"
git pull
git branch -a
