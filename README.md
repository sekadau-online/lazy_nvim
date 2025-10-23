# lazy_nvim
Lazy Nvim starter pack

#Compile menyesuaikan GLIBC
sudo apt install ninja-build gettext cmake unzip curl build-essential -y
git clone https://github.com/neovim/neovim.git
cd neovim
git checkout stable
make CMAKE_BUILD_TYPE=Release
sudo make install

#
sudo apt update
sudo apt install xclip -y
#

wget https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage
sudo mv nvim-linux-x86_64.appimage /usr/local/bin/nvim
#atau
sudo ln -s /path/to/nvim-linux-x86_64.appimage /usr/local/bin/nvim
#tanpa fuse
cd /usr/local/bin
sudo rm -f nvim
sudo wget https://github.com/neovim/neovim/releases/download/v0.9.5/nvim.appimage -O nvim
sudo chmod +x nvim

./nvim --appimage-extract
mv squashfs-root nvim-root
ln -sf /usr/local/bin/nvim-root/AppRun /usr/local/bin/nvim



git clone https://github.com/folke/lazy.nvim.git ~/.local/share/nvim/lazy/lazy.nvim

git clone https://github.com/sekadau-online/lazy_nvim.git ~/.config/nvim
